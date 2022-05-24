// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Hua Miu's Token
contract HuaMiuToken is ERC20, Ownable {
    uint256 public INIT_TOTALSUPPLY = 6_000_000 ether;

    constructor() ERC20("Hua Miu Token", "HMT") {
        transferOwnership(msg.sender);
        _mint(msg.sender, INIT_TOTALSUPPLY);
    }
}
