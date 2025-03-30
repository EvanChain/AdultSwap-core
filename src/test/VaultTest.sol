// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {console} from "forge-std/console.sol";

contract VaultTest is ERC4626 {
    constructor(address underlying) ERC4626(ERC20(underlying)) ERC20("TestVault", "TV") {}
}
