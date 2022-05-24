// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// for test, we create stable coin for ourself.
contract TokenXUSD is ERC20, Ownable {
    using SafeMath for uint256;

    constructor() ERC20("XUSDT for test", "xUSDT") {
        transferOwnership(msg.sender);
        _mint(msg.sender, 1_000_000_000_000_000_000_000_000_000);
    }

    function claimCoins() public {
        _mint(msg.sender, 1_000_000_000_000_000_000_000);
    }
}
