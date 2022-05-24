// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IKSTToken.sol";
import "./interfaces/IKSTFarmingProxy.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Implement KST's distrubution plan.
contract KSTMinter is Ownable {
    using SafeMath for uint256;

    /// @notice Info of each pool of proxy.
    struct PoolInfo {
        address pool; // Address of farming contract.
        uint256 allocPoint; // How many allocation points assigned to this proxy. KSTs to distribute per block.
        uint256 lastRewardBlock; // Last block number that KSTs distribution occurs.
    }
    IKSTToken public KSTToken;
    /// @notice Dev address.
    address public devaddr;
    /// @notice KST tokens created per block.
    uint256 public tokenPerBlock = 10_833_333_333_333_333_333; // 10.833333 cst/block
    /// @notice Info of each pool of proxy.
    mapping(address => mapping(address => PoolInfo)) public poolInfo;
    /// @notice Save proxy address whether exists.
    mapping(address => mapping(address => bool)) public proxyTokens;
    /// @notice Save proxy's address in array.
    address[] public proxyAddresses;
    /// @notice Save pool's address in array.
    mapping(address => address[]) public poolsAddress;
    /// @notice Save proxy whether exists.
    mapping(address => bool) public proxyExists;
    /// @notice Total allocation poitns. Must be the sum of all allocation points in all proxys.
    uint256 public totalAllocPoint = 0;
    /// @notice The block number when KST mining starts.
    uint256 public startBlock;
    /// @notice Halving Period in blocks.
    uint256 public halvingPeriod = 2_628_000;
    /// @notice Halving coefficient.
    uint256 public HALVING_COEFFICIENT = 1_189_207_115_002_721_024;

    event UpdateProxyInfo(
        address _farmingProxy,
        address _pool,
        uint256 _allocPoint,
        uint256 _totalAllocPoint
    );
    event UpdateToken(address _tokenAddress);
    event SetHalvingPeriod(uint256 _block);
    event SetDevAddress(address _dev);
    event MintKST(
        address proxy,
        address pool,
        uint256 lastRewardBock,
        uint256 blockNumber,
        uint256 amount
    );
    event PhaseChanged(address pool, uint256 phase, uint256 totalSupply);

    constructor(
        address _devaddr,
        uint256 _startBlock,
        address ownerAddress
    ) {
        require(
            _devaddr != address(0),
            "KSTMinter: dev address can't be 0 address"
        );
        devaddr = _devaddr;
        startBlock = _startBlock;
        transferOwnership(ownerAddress);
    }

    function setToken(IKSTToken _token) public onlyOwner {
        require(address(_token) != address(0), "KSTMinter: no 0 address");
        KSTToken = _token;
        emit UpdateToken(address(_token));
    }

    function setHalvingPeriod(uint256 _block) public onlyOwner {
        halvingPeriod = _block;
        emit SetHalvingPeriod(_block);
    }

    /// @notice Owner should add proxy first, then proxy can add its pools.
    /// @param _farmingProxy Proxy's address
    function addProxy(address _farmingProxy) public onlyOwner {
        require(_farmingProxy != address(0), "KSTMinter: no 0 address");
        require(
            !proxyExists[_farmingProxy],
            "KSTMinter: _farmingProxy is exists."
        );
        proxyAddresses.push(_farmingProxy);
        proxyExists[_farmingProxy] = true;
    }

    /// @notice Add a new proxy. Can only be called by the owner.
    /// @param _allocPoint Proxy's allocation's weight.
    /// @param _poolAddress A pool of the proxy.
    function add(uint256 _allocPoint, address _poolAddress) public {
        require(proxyExists[msg.sender], "KSTMinter: only proxy contract");
        require(_poolAddress != address(0), "KSTMinter: no 0 address");
        require(
            !proxyTokens[msg.sender][_poolAddress],
            "KSTMinter: _farmingProxy and pool already exist"
        );
        proxyTokens[msg.sender][_poolAddress] = true;
        uint256 lastRewardBlock =
            block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        PoolInfo memory pInfo = poolInfo[msg.sender][_poolAddress];
        pInfo.pool = _poolAddress;
        pInfo.allocPoint = _allocPoint;
        pInfo.lastRewardBlock = lastRewardBlock;
        poolInfo[msg.sender][_poolAddress] = pInfo;
        poolsAddress[msg.sender].push(_poolAddress);
        emit UpdateProxyInfo(
            msg.sender,
            _poolAddress,
            _allocPoint,
            totalAllocPoint
        );
    }

    /// @notice Update the given proxy's KST allocation point. Can only be called by the owner.
    /// @param _poolAddress A pool of the proxy.
    /// @param _allocPoint Proxy's allocation's weight.
    function set(address _poolAddress, uint256 _allocPoint) public {
        require(proxyExists[msg.sender], "KSTMinter: only proxy contract");
        require(_poolAddress != address(0), "KSTMinter: no 0 address");
        totalAllocPoint = totalAllocPoint
            .sub(poolInfo[msg.sender][_poolAddress].allocPoint)
            .add(_allocPoint);
        poolInfo[msg.sender][_poolAddress].allocPoint = _allocPoint;
        emit UpdateProxyInfo(
            msg.sender,
            _poolAddress,
            _allocPoint,
            totalAllocPoint
        );
    }

    function massUpdateProxyForOwner() public onlyOwner {
        for (uint256 i; i < proxyAddresses.length; i++) {
            IKSTFarmingProxy(proxyAddresses[i]).massUpdate();
        }
    }

    function massUpdateProxy() public {
        require(proxyExists[msg.sender], "KSTMinter: only proxy contract");
        for (uint256 i; i < proxyAddresses.length; i++) {
            IKSTFarmingProxy(proxyAddresses[i]).massUpdate();
        }
    }

    function _phase(uint256 blockNumber) internal view returns (uint256) {
        if (halvingPeriod == 0) {
            return 0;
        }
        if (blockNumber > startBlock) {
            return (blockNumber.sub(startBlock).sub(1)).div(halvingPeriod);
        }
        return 0;
    }

    /// @notice At what phase
    function phase() public view returns (uint256) {
        return _phase(block.number);
    }

    /// @notice Get proxy's amount of total reward
    /// @param _proxyAddress the proxy's address.
    /// @param _poolAddress A pool of the proxy.
    /// @return return the amount of bst should be mint.
    function getReward(address _proxyAddress, address _poolAddress)
        public
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_proxyAddress][_poolAddress];
        if (block.number <= pool.lastRewardBlock) {
            return 0;
        }
        uint256 _lastRewardBlock = pool.lastRewardBlock;
        uint256 blockReward = 0;
        uint256 _lastPhase = _phase(_lastRewardBlock);
        uint256 _currPhase = _phase(block.number);
        uint256 _bstPerBlock = tokenPerBlock;
        uint256 i = 1;
        while (i <= _lastPhase) {
            // calculate out lastPhase _bstPerBlock
            _bstPerBlock = _bstPerBlock.mul(10**18).div(HALVING_COEFFICIENT);
            i++;
        }
        // If it crosses the cycle
        while (_lastPhase < _currPhase) {
            _lastPhase++;
            // Get the last block of the previous cycle
            uint256 r = _lastPhase.mul(halvingPeriod).add(startBlock);
            // Get rewards from previous periods
            blockReward = blockReward.add(
                r
                    .sub(_lastRewardBlock)
                    .mul(_bstPerBlock)
                    .mul(pool.allocPoint)
                    .div(totalAllocPoint)
            );
            _bstPerBlock = _bstPerBlock.mul(10**18).div(HALVING_COEFFICIENT);
            _lastRewardBlock = r;
        }
        blockReward = blockReward.add(
            (block.number.sub(_lastRewardBlock))
                .mul(_bstPerBlock)
                .mul(pool.allocPoint)
                .div(totalAllocPoint)
        );
        return blockReward;
    }

    /// @notice mint bst according options
    /// @param _pid proxy's address
    /// @param _pool pool's address.
    function mint_(address _pid, address _pool) internal returns (uint256) {
        PoolInfo storage pInfo = poolInfo[_pid][_pool];
        uint256 _lastRewardBlock = pInfo.lastRewardBlock;
        if (block.number <= pInfo.lastRewardBlock) {
            return 0;
        }
        uint256 _lastPhase = _phase(_lastRewardBlock);
        uint256 _currPhase = _phase(block.number);
        if (_currPhase > _lastPhase) {
            emit PhaseChanged(_pool, _currPhase, KSTToken.totalSupply());
        }
        uint256 tokenReward = getReward(_pid, _pool);
        KSTToken.mint(devaddr, tokenReward.div(10));
        KSTToken.mint(_pid, tokenReward);
        pInfo.lastRewardBlock = block.number;
        emit MintKST(_pid, _pool, _lastRewardBlock, block.number, tokenReward);
        return tokenReward;
    }

    /// @dev Update pool's lastRewardBlock to block.number
    /// @param pool Pool's address
    function updateLastRewardBlock(address pool) public {
        require(proxyTokens[msg.sender][pool], "KSTMinter: only farmingProxy");
        PoolInfo storage pInfo = poolInfo[msg.sender][pool];
        uint256 _lastRewardBlock = pInfo.lastRewardBlock;
        uint256 _lastPhase = _phase(_lastRewardBlock);
        uint256 _currPhase = _phase(block.number);
        if (_currPhase > _lastPhase) {
            emit PhaseChanged(pool, _currPhase, KSTToken.totalSupply());
        }
        poolInfo[msg.sender][pool].lastRewardBlock = block.number;
    }

    /// @notice mint bst according options
    /// @param pool pool's address.
    function mint(address pool) external returns (uint256) {
        require(proxyExists[msg.sender], "KSTMinter: only proxy contract");
        require(
            proxyTokens[msg.sender][pool],
            "KSTMinter: proxy and pool no exists."
        );
        return mint_(msg.sender, pool);
    }

    /// @notice Update dev address by the previous dev.
    function dev(address _devaddr) public onlyOwner {
        require(
            _devaddr != address(0),
            "KSTMinter: dev address can't be 0 address"
        );
        devaddr = _devaddr;
        emit SetDevAddress(_devaddr);
    }

    function getTokenAddress() external view returns (address) {
        return address(KSTToken);
    }

    function getStartBlock() external view returns (uint256) {
        return startBlock;
    }

    function getPoolInfo(address _proxy, address _pool)
        external
        view
        returns (uint256 _allocPoint, uint256 _lastRewardBlock)
    {
        _allocPoint = poolInfo[_proxy][_pool].allocPoint;
        _lastRewardBlock = poolInfo[_proxy][_pool].lastRewardBlock;
    }
}
