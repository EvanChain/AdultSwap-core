// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SafeCast} from "../libraries/SafeCast.sol";

using SafeCast for uint256;
using SafeCast for int256;

struct LiquidityBuffer {
    // Minimum Liquidity Amount
    uint256 minBalance;
    // Maximum Liquidity Amount
    uint256 maxBalance;
    // Target Liquidity Amount
    uint256 targetBalance;
}

error LiquidityBufferInvalid();

library LiquidityBufferLibrary {
    /// @notice Updates the liquidity buffer
    /// @param liquidityBuffer The liquidity buffer
    /// @param minBalance The minimum balance of the liquidity buffer
    /// @param maxBalance The maximum balance of the liquidity buffer
    /// @param targetBalance The target balance of the liquidity buffer
    function update(
        LiquidityBuffer memory liquidityBuffer,
        uint256 minBalance,
        uint256 maxBalance,
        uint256 targetBalance
    ) internal pure {
        if (minBalance >= targetBalance || targetBalance >= maxBalance) revert LiquidityBufferInvalid();
        liquidityBuffer.minBalance = minBalance;
        liquidityBuffer.maxBalance = maxBalance;
        liquidityBuffer.targetBalance = targetBalance;
    }

    /// @notice Returns the amount of liquidity to release based on the current balance and the target balance
    /// @param liquidityBuffer The liquidity buffer
    /// @param tokenBalance The current balance of the token
    /// @param deltaAmount The change in balance
    /// @return The amount of liquidity to release
    function getReleaseAmount(LiquidityBuffer memory liquidityBuffer, uint256 tokenBalance, int256 deltaAmount)
        internal
        pure
        returns (int256)
    {
        int256 newBalance = tokenBalance.toInt256() - deltaAmount;
        // If the new balance is below the minimum balance, release the difference between the target balance and the new balance
        if (newBalance < liquidityBuffer.minBalance.toInt256() || newBalance > liquidityBuffer.maxBalance.toInt256()) {
            return liquidityBuffer.targetBalance.toInt256() - newBalance;
        }
        return 0;
    }
}
