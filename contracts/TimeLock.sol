// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./lib/TransferHelper.sol";

contract TimeLock {
    using SafeMath for uint256;

    IERC20 public token;
    uint256 public constant PERIOD = 30 days;
    uint256 public constant CYCLE_TIMES = 12;
    uint256 public fixedQuantity = 500_000 ether; // Monthly rewards are fixed
    uint256 public startTime;
    uint256 public delay;
    uint256 public cycle; // cycle already received
    uint256 public hasReward; // Rewards already withdrawn
    address public beneficiary;
    string public name = "CST Investors Time Lock";
    string public symbol = "CST-ITL";

    event WithDraw(
        address indexed operator,
        address indexed to,
        uint256 amount
    );

    constructor(
        address _beneficiary,
        address _token,
        uint256 _startTime,
        uint256 _delay
    ) {
        require(
            _beneficiary != address(0) && _token != address(0),
            "TimeLock: zero address"
        );
        beneficiary = _beneficiary;
        token = IERC20(_token);
        delay = _delay;
        startTime = _startTime.add(_delay);
    }

    function getBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function getReward() public view returns (uint256) {
        // Has ended or not started
        if (cycle >= CYCLE_TIMES || block.timestamp <= startTime) {
            return 0;
        }
        uint256 pCycle = (block.timestamp.sub(startTime)).div(PERIOD);
        if (pCycle >= CYCLE_TIMES) {
            return token.balanceOf(address(this));
        }
        return pCycle.sub(cycle).mul(fixedQuantity);
    }

    function withdraw() external {
        uint256 reward = getReward();
        require(reward > 0, "TimeLock: no reward");
        uint256 pCycle = (block.timestamp.sub(startTime)).div(PERIOD);
        cycle = pCycle >= CYCLE_TIMES ? CYCLE_TIMES : pCycle;
        hasReward = hasReward.add(reward);
        TransferHelper.safeTransfer(address(token), beneficiary, reward);
        emit WithDraw(msg.sender, beneficiary, reward);
    }

    // Update beneficiary address by the previous beneficiary.
    function setBeneficiary(address _newBeneficiary) public {
        require(msg.sender == beneficiary, "Not beneficiary");
        beneficiary = _newBeneficiary;
    }
}
