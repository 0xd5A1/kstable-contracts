// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title KSTToken with Governance.
contract KSTToken is ERC20Votes, Ownable {
    address public minter;

    uint256 public TOKENS_PER_INVESTOR = 1_000_000 ether;

    constructor(
        address owner_,
        address minter_,
        address[] memory investors
    ) ERC20("CStable Token", "CST") ERC20Permit("CStable Token") {
        require(investors.length == 10, "only have 10 investor address");
        require(owner_ != minter_, "owner can't be minter.");
        require(minter_ != address(0), "minter_ can't be 0 address");
        transferOwnership(owner_);
        minter = minter_;
        for (uint256 i = 0; i < 10; i++) {
            _mint(investors[i], TOKENS_PER_INVESTOR);
        }
    }

    /// @notice Creates `_amount` token to `_to`.
    function mint(address _to, uint256 _amount) public {
        require(msg.sender == minter, "only minter.");
        require(_to != address(0), "no 0 address");
        _mint(_to, _amount);
    }
}
