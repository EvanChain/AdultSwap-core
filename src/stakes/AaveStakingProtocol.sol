// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IStakingProtocol} from "../interfaces/IStakingProtocol.sol";
import {IAaveV3Minimal} from "../interfaces/external/IAaveV3Minimal.sol";
import {IERC20Minimal} from "../interfaces/external/IERC20Minimal.sol";
import {OnlyDelegateCall} from "../OnlyDelegateCall.sol";

contract AaveStakingProtocol is IStakingProtocol, OnlyDelegateCall {
    address public immutable aave;
    uint16 public immutable referralCode;

    constructor(address _aave, uint16 _referralCode) {
        aave = _aave;
        referralCode = _referralCode;
    }

    function totalAssets(address asset) external view override onlyDelegateCall returns (uint256) {
        IERC20Minimal aToken = IERC20Minimal(IAaveV3Minimal(aave).getReserveData(asset).aTokenAddress);
        return aToken.balanceOf(address(this));
    }

    function deposit(address asset, uint256 amount) external payable override onlyDelegateCall {
        IERC20Minimal(asset).approve(aave, amount);
        IAaveV3Minimal(aave).supply(asset, amount, address(this), referralCode);
    }

    function withdraw(address asset, address to, uint256 amount) external override onlyDelegateCall {
        IERC20Minimal aToken = IERC20Minimal(IAaveV3Minimal(aave).getReserveData(asset).aTokenAddress);
        aToken.approve(aave, amount);
        IAaveV3Minimal(aave).withdraw(asset, amount, to);
    }
}
