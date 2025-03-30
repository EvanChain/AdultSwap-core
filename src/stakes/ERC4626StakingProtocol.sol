// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IStakingProtocol} from "../interfaces/IStakingProtocol.sol";
import {IERC4626Minimal} from "../interfaces/external/IERC4626Minimal.sol";
import {IERC20Minimal} from "../interfaces/external/IERC20Minimal.sol";
import {OnlyDelegateCall} from "../OnlyDelegateCall.sol";

contract ERC4626StakingProtocol is IStakingProtocol, OnlyDelegateCall {
    error InvalidAssetOrVault();

    address public immutable asset;
    address public immutable erc4626Vault;

    constructor(address _asset, address _erc4626Vault) {
        if (_asset == address(0) || IERC4626Minimal(_erc4626Vault).asset() != _asset) {
            revert InvalidAssetOrVault();
        }
        asset = _asset;
        erc4626Vault = _erc4626Vault;
    }

    function totalAssets(address) external view override onlyDelegateCall returns (uint256) {
        uint256 shareBalance = IERC20Minimal(erc4626Vault).balanceOf(address(this));
        return IERC4626Minimal(erc4626Vault).previewRedeem(shareBalance);
    }

    function deposit(address, uint256 amount) external payable override onlyDelegateCall {
        IERC4626Minimal(erc4626Vault).deposit(amount, address(this));
    }

    function withdraw(address, address to, uint256 amount) external override onlyDelegateCall {
        IERC4626Minimal(erc4626Vault).withdraw(amount, to, address(this));
    }
}
