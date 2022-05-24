// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IKSTMinter.sol";
import "./interfaces/IKStablePool.sol";
import "./interfaces/IKSTToken.sol";
import "./interfaces/IKSTFarmingProxy.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./lib/TransferHelper.sol";

/// @title Implement Payment and payment farming.
contract PaymentFarmingProxy is ERC20, Ownable, IKSTFarmingProxy {
    using SafeMath for uint256;

    IKStablePool public pool;

    uint256 public paymentFee = 3_000_000_000_000_000;

    IKSTMinter public bstMinter;

    address public devAddress;

    struct UserInfo {
        uint256 quantity; // user's volume
        uint256 blockNumber; // Last transaction block
    }

    mapping(address => UserInfo) public userInfo;

    uint256 public totalQuantity;

    IKSTToken public token;

    struct CoinInfo {
        uint256 index;
        bool available;
    }
    mapping(address => CoinInfo) public coins;

    modifier onlyMinter() {
        require(
            address(bstMinter) == msg.sender,
            "PaymentFarmingProxy: caller is not the bstMinter"
        );
        _;
    }

    event SetPaymentFee(uint256 _fee);
    event SetMinter(IKSTMinter _minter);
    event SetDev(address _dev);
    event SetToken(IKSTToken _token);
    event AddCoins(address _coin, uint32 index);
    event RemoveCoins(address _coin);
    event SetPool(IKStablePool _pool);
    event Pay(
        address payToken,
        address receiptToken,
        address payer,
        address recipt
    );

    event WithdrawReward(
        uint256 _quantity,
        uint256 _totalQuantity,
        uint256 _userReward
    );

    constructor(
        string memory _name,
        string memory _symbol,
        address _owner,
        address _dev
    ) ERC20(_name, _symbol) {
        require(
            _dev != address(0),
            "PaymentFarmingProxy: _dev can't be 0 address"
        );
        transferOwnership(_owner);
        devAddress = _dev;
    }

    function setPaymentFee(uint256 _fee) public onlyOwner {
        paymentFee = _fee;
        emit SetPaymentFee(_fee);
    }

    function setMinter(IKSTMinter _minter) public onlyOwner {
        require(
            address(_minter) != address(0),
            "PaymentFarmingProxy: can't be 0 address"
        );
        bstMinter = _minter;
        emit SetMinter(_minter);
    }

    function add(uint256 _allocPoint) public onlyOwner {
        bstMinter.add(_allocPoint, address(this));
    }

    function set(uint256 _allocPoint) public onlyOwner {
        bstMinter.massUpdateProxy();
        bstMinter.set(address(this), _allocPoint);
    }

    /// @dev Mass update pools. Only caller is KSTMinter's massUpdateProxy.
    function massUpdate() public override onlyMinter {
        bstMinter.mint(address(this));
    }

    function setDev(address _dev) public onlyOwner {
        require(_dev != address(0), "PaymentFarmingProxy: can't be 0 address");
        devAddress = _dev;
        emit SetDev(_dev);
    }

    function setToken(IKSTToken _token) public onlyOwner {
        require(
            address(_token) != address(0),
            "PaymentFarmingProxy: can't be 0 address"
        );
        token = _token;
        emit SetToken(_token);
    }

    /// @notice Add coins supported.
    function addCoins(address _coin, uint32 index) public onlyOwner {
        require(_coin != address(0), "PaymentFarmingProxy: can't be 0 address");
        require(!coins[_coin].available, "Payment: coins dumplicated.");
        coins[_coin] = CoinInfo({index: index, available: true});
        emit AddCoins(_coin, index);
    }

    /// @notice Remove coins from supported.
    function removeCoins(address _coin) public onlyOwner {
        require(_coin != address(0), "PaymentFarmingProxy: can't be 0 address");
        require(coins[_coin].available, "Payment: coin no exists.");
        coins[_coin].available = false;
        emit RemoveCoins(_coin);
    }

    function setPool(IKStablePool _pool) public onlyOwner {
        require(
            address(_pool) != address(0),
            "PaymentFarmingProxy: can't be 0 address"
        );
        pool = _pool;
        emit SetPool(_pool);
    }

    /// @notice Only pay, no need swap.
    function pay(
        address receiptToken,
        address receipt,
        uint256 amt
    ) external {
        require(receiptToken != address(0), "Payment:receiptToken can't be 0");
        require(receipt != address(0), "Payment:receipt can't be 0");
        require(coins[receiptToken].available, "Payment: token no exists.");
        require(
            amt <= IERC20(receiptToken).balanceOf(msg.sender),
            "Payment: insufficient balance."
        );
        uint256 decimals = ERC20(receiptToken).decimals();
        bstMinter.mint(address(this));
        uint256 fee = amt.mul(paymentFee).div(10**18);
        UserInfo storage user = userInfo[msg.sender];
        user.quantity = user.quantity.add(
            amt.mul(10**18).div(10**decimals).sub(
                fee.mul(10**18).div(10**decimals)
            )
        );
        userInfo[msg.sender].blockNumber = block.number;
        totalQuantity = totalQuantity.add(
            amt.mul(10**18).div(10**decimals).sub(
                fee.mul(10**18).div(10**decimals)
            )
        );
        TransferHelper.safeTransferFrom(
            receiptToken,
            msg.sender,
            devAddress,
            fee
        );
        TransferHelper.safeTransferFrom(
            receiptToken,
            msg.sender,
            receipt,
            amt.sub(fee)
        );
        emit Pay(receiptToken, receiptToken, msg.sender, receipt);
    }

    /// @notice Pay, and use swap.
    function payWithSwap(
        address payToken,
        address receiptToken,
        uint256 payAmt,
        uint256 receiptAmt,
        address receipt
    ) external {
        require(payToken != receiptToken, "Payment: the same token.");
        bstMinter.mint(address(this));
        uint256 i = coins[payToken].index;
        uint256 j = coins[receiptToken].index;
        TransferHelper.safeTransferFrom(
            payToken,
            msg.sender,
            address(this),
            payAmt
        );
        TransferHelper.safeApprove(payToken, address(pool), payAmt);
        uint256 _originalBalance = IERC20(receiptToken).balanceOf(
            address(this)
        );
        pool.exchange(i, j, payAmt, receiptAmt);
        uint256 returnAmt = IERC20(receiptToken).balanceOf(address(this)).sub(
            _originalBalance
        );
        require(returnAmt >= receiptAmt, "Payment: swap amt insufficient.");
        uint256 decimals = ERC20(receiptToken).decimals();
        UserInfo storage user = userInfo[msg.sender];
        user.quantity = user.quantity.add(
            receiptAmt.mul(10**18).div(10**decimals)
        );
        userInfo[msg.sender].blockNumber = block.number;
        totalQuantity = totalQuantity.add(
            receiptAmt.mul(10**18).div(10**decimals)
        );
        TransferHelper.safeTransfer(receiptToken, receipt, receiptAmt);
        TransferHelper.safeTransfer(
            receiptToken,
            msg.sender,
            returnAmt.sub(receiptAmt)
        );
        emit Pay(payToken, receiptToken, msg.sender, receipt);
    }

    /// @notice The user withdraws all the payment rewards
    function withdrawReward() public {
        UserInfo storage user = userInfo[msg.sender];
        uint256 _quantity = user.quantity;
        uint256 _totalQuantity = totalQuantity;
        require(user.quantity > 0, "Payment: no payment quantity.");
        bstMinter.mint(address(this));
        uint256 userReward = token.balanceOf(address(this)).mul(_quantity).div(
            _totalQuantity
        );
        user.quantity = 0;
        user.blockNumber = block.number;
        totalQuantity = totalQuantity.sub(_quantity);
        TransferHelper.safeTransfer(address(token), msg.sender, userReward);
        emit WithdrawReward(_quantity, _totalQuantity, userReward);
    }

    /// @notice Get rewards from users in the current pool
    function getUserReward(address _user) public view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 _quantity = user.quantity;
        uint256 userReward = 0;
        if (totalQuantity > 0) {
            userReward = token.balanceOf(address(this)).mul(_quantity).div(
                totalQuantity
            );
        }
        return userReward;
    }
}
