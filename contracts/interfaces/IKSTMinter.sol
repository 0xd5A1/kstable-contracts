// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IKSTToken.sol";

interface IKSTMinter {
    function setToken(IKSTToken _token) external;

    function setHalvingPeriod(uint256 _block) external;

    function add(uint256 _allocPoint, address _poolAddress) external;

    function set(address _poolAddress, uint256 _allocPoint) external;

    function phase(uint256 blockNumber) external view returns (uint256);

    function phase() external view returns (uint256);

    function getReward(address _proxy, address _pool)
        external
        view
        returns (uint256);

    function massMint() external;

    function mint(address pool) external returns (uint256);

    function dev(address _devaddr) external;

    function getTokenAddress() external view returns (address);

    function getStartBlock() external view returns (uint256);

    function getPoolInfo(address _proxy, address _pool)
        external
        view
        returns (uint256 _allocPoint, uint256 _lastRewardBlock);

    function updateLastRewardBlock(address pool) external;

    function massUpdateProxy() external;
}
