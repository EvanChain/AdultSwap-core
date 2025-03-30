// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {Buffer} from "./libraries/Buffer.sol";
import {LiquidityBuffer, LiquidityBufferLibrary} from "./types/LiquidityBuffer.sol";
import {Currency, CurrencyLibrary} from "./types/Currency.sol";
import {SafeCast} from "./libraries/SafeCast.sol";
import {Extsload} from "./Extsload.sol";

abstract contract LiquidityManager {
    using Buffer for Buffer.State;
    using SafeCast for *;
    using LiquidityBufferLibrary for LiquidityBuffer;
    using CurrencyLibrary for Currency;

    bytes32 internal constant _BUFFER_STORAGE_POSITION = keccak256("v4.core.LiquidityManager._buffers");

    function _setBuffer(Currency currency, Buffer.State storage state) internal {
        Buffer.State storage s = _buffer(currency);
        s.stakingProtocol = state.stakingProtocol;
        s.liquidityBuffer = state.liquidityBuffer;
    }

    function _buffer(Currency currency) private pure returns (Buffer.State storage s) {
        bytes32 position = keccak256(abi.encode(_BUFFER_STORAGE_POSITION, currency));
        assembly {
            s.slot := position
        }
    }

    function _doBuffer(Currency currency, int256 deltaAmount, address target) internal {
        if (deltaAmount == 0) return;
        (IStakingProtocol stakingProtocol, int256 releaseAmount) = _buffer(currency).doBuffer(currency, deltaAmount);
        if (releaseAmount > 0) {
            // release
            stakingProtocol.withdraw(Currency.unwrap(currency), address(this), uint256(releaseAmount));
            _accountDelta(currency, releaseAmount, target);
        }else if (releaseAmount < 0) {
            _accountDelta(currency, releaseAmount, target);
            // deposit
            stakingProtocol.deposit(Currency.unwrap(currency), uint256(-releaseAmount));
        }else{
            _accountDelta(currency, releaseAmount, target);
        }
    }
}
