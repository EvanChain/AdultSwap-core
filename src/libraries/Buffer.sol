// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {SafeCast} from "./SafeCast.sol";
import {LiquidityBuffer, LiquidityBufferLibrary} from "../types/LiquidityBuffer.sol";
import {IStakingProtocol} from "../interfaces/IStakingProtocol.sol";

library Buffer {
    using LiquidityBufferLibrary for LiquidityBuffer;
    using SafeCast for uint256;

    struct State {
        uint256 totalAssets;
        LiquidityBuffer liquidityBuffer;
        IStakingProtocol stakingProtocol;
    }

    function updateTotalAssets(State storage state, uint256 totalAssets) internal {
        state.totalAssets = totalAssets;
    }

    /// @notice Buffer the liquidity
    /// @param state The state of the buffer
    /// @param tokenBalance The current balance of the token
    /// @param deltaAmount The change in balance
    function doBuffer(State storage state, uint256 tokenBalance, int256 deltaAmount) internal {
        if (state.stakingProtocol == IStakingProtocol(address(0))) return;
        int256 releaseAmount = state.liquidityBuffer.getReleaseAmount(tokenBalance, deltaAmount);
        if (releaseAmount > 0) {
            unchecked {
                state.stakingProtocol.withdraw(address(this), uint256(releaseAmount));
            }
        } else if (releaseAmount < 0) {
            unchecked {
                state.stakingProtocol.deposit(uint256(-releaseAmount));
            }
        } else {
            return;
        }
    }

    /// @notice Update the total assets of the buffer
    /// @param state The state of the buffer
    function updateLiquidity(State storage state) internal {
        if (state.stakingProtocol == IStakingProtocol(address(0))) return;
        state.totalAssets = state.stakingProtocol.totalAssets();
    }
}
