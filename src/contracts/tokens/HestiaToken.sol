// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@solady/tokens/ERC20.sol";

/// @title HestiaToken
/// @notice Currently unused.
contract HestiaToken is ERC20 {
    constructor() {}

    function name() public pure override returns (string memory _name) {
        _name = "Mock";
    }

    function symbol() public pure override returns (string memory _symbol) {
        _symbol = "MOCK";
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}