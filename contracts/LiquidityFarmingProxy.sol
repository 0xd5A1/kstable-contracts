// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IKStablePool.sol";
import "./interfaces/IKSTMinter.sol";
import "./interfaces/IKSTToken.sol";
import "./interfaces/IKSTFarmingProxy.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./lib/TransferHelper.sol";

/// @title Implement liquitidy farming.
contract LiquidityFarmingProxy is Ownable, IKSTFarmingProxy {
    using SafeMath for uint256;
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }
    /// @notice Info of each pool.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 accTokenPerShare; // Accumulated KSTs per share, times 1e12. See below.
    }
    string public name = "KStable Liquidity Farming Proxy";
    string public symbol = "CLFP-V1";
    IKSTToken public token;
    /// @notice Info of each pool.
    PoolInfo[] public poolInfo;
    /// @notice Save lp tokens whether exists.
    mapping(address => bool) public lpTokens;
    /// @notice Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    /// @notice For mint KST
    IKSTMinter public minter;

    modifier onlyMinter() {
        require(address(minter) == msg.sender, "caller is not the minter");
        _;
    }
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event SetMinter(address _minter);
    event AddPool(address _poolAddress);
    event SetPool(uint256 _pid);
    event UpdatePool(
        uint256 _pid,
        uint256 accTokenPerShare,
        uint256 _tokenReward
    );
    event CalculatePending(
        uint256 _pid,
        uint256 _amount,
        uint256 rewardDebt,
        uint256 accTokenPerShare,
        uint256 pending
    );
    event SetToken(address _token);
    event ZeroLPStaking(
        uint256 _pid,
        uint256 _lastRewardBlock,
        uint256 blockNumber
    );

    constructor(address ownerAddress) {
        require(ownerAddress != address(0), "no 0 address");
        transferOwnership(ownerAddress);
    }

    function setMinter(IKSTMinter _minter) public onlyOwner {
        require(address(_minter) != address(0), "no 0 address");
        minter = _minter;
        emit SetMinter(address(_minter));
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    /// @notice Add a new lp to the pool. Can only be called by the owner.
    function add(
        IERC20 _lpToken,
        uint256 _allocPoint,
        bool _withUpdate
    ) external onlyOwner {
        require(address(_lpToken) != address(0), "no 0 address");
        require(!lpTokens[address(_lpToken)], "_lpToken already exist");
        lpTokens[address(_lpToken)] = true;
        if (_withUpdate) {
            minter.massUpdateProxy();
        }
        minter.add(_allocPoint, address(_lpToken));
        poolInfo.push(PoolInfo({lpToken: _lpToken, accTokenPerShare: 0}));
        emit AddPool(address(_lpToken));
    }

    /// @notice Update the given pool's KST allocation point. Can only be called by the owner.
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) external onlyOwner {
        require(_pid < poolInfo.length, "pid out of range.");
        if (_withUpdate) {
            minter.massUpdateProxy();
        }
        minter.set(address(poolInfo[_pid].lpToken), _allocPoint);
        emit SetPool(_pid);
    }

    /// @notice View function to see pending KSTs on frontend.
    function pendingReward(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accTokenPerShare = pool.accTokenPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        (, uint256 _lastRewardBlock) = minter.getPoolInfo(
            address(this),
            address(pool.lpToken)
        );
        if (block.number > _lastRewardBlock && lpSupply != 0) {
            uint256 tokenReward = minter.getReward(
                address(this),
                address(pool.lpToken)
            );
            uint256 nAccTokenPerShare = tokenReward == 0
                ? 0
                : tokenReward.mul(1e12).div(lpSupply);
            accTokenPerShare = accTokenPerShare.add(nAccTokenPerShare);
        }
        return user.amount.mul(accTokenPerShare).div(1e12).sub(user.rewardDebt);
    }

    /// @dev Mass update pools. Only caller is minter's massUpdateProxy.
    function massUpdate() public override onlyMinter {
        _massUpdatePools();
    }

    /// @notice Update reward vairables for all pools. Be careful of gas spending!
    function _massUpdatePools() internal {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            _updatePool(pid);
        }
    }

    /// @notice Update reward variables of the given pool to be up-to-date.
    /// @param _pid pool's index.
    function _updatePool(uint256 _pid) internal {
        require(
            _pid < poolInfo.length,
            "LiqudityFarmingProxy: pid out of range."
        );
        PoolInfo storage pool = poolInfo[_pid];
        (, uint256 _lastRewardBlock) = minter.getPoolInfo(
            address(this),
            address(pool.lpToken)
        );
        if (block.number <= _lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            minter.updateLastRewardBlock(address(pool.lpToken));
            emit ZeroLPStaking(_pid, _lastRewardBlock, block.number);
            return;
        }
        uint256 tokenReward = minter.mint(address(pool.lpToken));
        pool.accTokenPerShare = pool.accTokenPerShare.add(
            tokenReward.mul(1e12).div(lpSupply)
        );
        emit UpdatePool(_pid, pool.accTokenPerShare, tokenReward);
    }

    /// @notice Deposit LP tokens to BStableProxyV2 for KST allocation.
    function deposit(uint256 _pid, uint256 _amount) public {
        require(
            _pid < poolInfo.length,
            "LiqudityFarmingProxy: pid out of range."
        );
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        _updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user
                .amount
                .mul(pool.accTokenPerShare)
                .div(1e12)
                .sub(user.rewardDebt);
            emit CalculatePending(
                _pid,
                user.amount,
                user.rewardDebt,
                pool.accTokenPerShare,
                pending
            );
            safeTokenTransfer(msg.sender, pending);
        }
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
        if (_amount > 0) {
            TransferHelper.safeTransferFrom(
                address(pool.lpToken),
                address(msg.sender),
                address(this),
                _amount
            );
        }
        emit Deposit(msg.sender, _pid, _amount);
    }

    /// @notice Withdraw LP tokens .
    function withdraw(uint256 _pid, uint256 _amount) public {
        require(
            _pid < poolInfo.length,
            "LiqudityFarmingProxy: pid out of range."
        );
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        _updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accTokenPerShare).div(1e12).sub(
            user.rewardDebt
        );
        emit CalculatePending(
            _pid,
            user.amount,
            user.rewardDebt,
            pool.accTokenPerShare,
            pending
        );
        if (pending > 0) {
            safeTokenTransfer(msg.sender, pending);
        }
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
        if (_amount > 0) {
            TransferHelper.safeTransfer(
                address(pool.lpToken),
                address(msg.sender),
                _amount
            );
        }
        emit Withdraw(msg.sender, _pid, _amount);
    }

    /// @notice Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        require(
            _pid < poolInfo.length,
            "LiqudityFarmingProxy: pid out of range."
        );
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount_ = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        TransferHelper.safeTransfer(
            address(pool.lpToken),
            address(msg.sender),
            amount_
        );
        emit EmergencyWithdraw(msg.sender, _pid, amount_);
    }

    /// @notice Safe token transfer function, just in case if rounding error causes pool to not have enough KSTs.
    function safeTokenTransfer(address _to, uint256 _amount) internal {
        require(_to != address(0), "LiquidityFarmingProxy: no 0 address");
        uint256 tokenBal = token.balanceOf(address(this));
        if (_amount > tokenBal) {
            token.transfer(_to, tokenBal);
        } else {
            token.transfer(_to, _amount);
        }
    }

    function setToken(IKSTToken _token) external onlyOwner {
        require(
            address(_token) != address(0),
            "LiquidityFarmingProxy: no 0 address"
        );
        token = _token;
        emit SetToken(address(_token));
    }

    function getTokenAddress() external view returns (address) {
        return address(token);
    }
}
