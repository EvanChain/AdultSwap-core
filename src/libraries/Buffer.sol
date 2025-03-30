// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {SafeCast} from "./SafeCast.sol";
import {LiquidityBuffer, LiquidityBufferLibrary} from "../types/LiquidityBuffer.sol";
import {IStakingProtocol} from "../interfaces/IStakingProtocol.sol";
import {Currency, CurrencyLibrary} from "../types/Currency.sol";

library Buffer {
    using LiquidityBufferLibrary for LiquidityBuffer;
    using SafeCast for uint256;
    using CurrencyLibrary for Currency;

    struct State {
        // The total income = stakingProtocol.totalAssets() - totalPrincipal
        uint256 totalPrincipal;
        LiquidityBuffer liquidityBuffer;
        IStakingProtocol stakingProtocol;
        // The share amount of user = currency provided / stakingProtocol.totalAssets()
        // The income of user = totalIncome * userShare / stakingProtocol.totalAssets()
        mapping(address => uint256) userShares;
    }

    function updateTotalPrincipal(State storage state, uint256 totalPrincipal) internal {
        state.totalPrincipal = totalPrincipal;
    }

    /// @notice Buffer the liquidity
    /// @param state The state of the buffer
    /// @param currency The currency to buffer
    /// @param deltaAmount The change in balance
    function doBuffer(State storage state, Currency currency, int256 deltaAmount)
        internal
        view
        returns (IStakingProtocol stakingProtocol, int256 releaseAmount)
    {
        uint256 tokenBalance = currency.balanceOfSelf();
        stakingProtocol = state.stakingProtocol;
        if (stakingProtocol == IStakingProtocol(address(0))) return (stakingProtocol, 0);
        releaseAmount = state.liquidityBuffer.getReleaseAmount(tokenBalance, deltaAmount);
    }
}
