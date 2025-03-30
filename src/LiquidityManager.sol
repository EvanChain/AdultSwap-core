// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {Buffer} from "./libraries/Buffer.sol";
import {LiquidityBuffer, LiquidityBufferLibrary} from "./types/LiquidityBuffer.sol";
import {Currency, CurrencyLibrary} from "./types/Currency.sol";
import {SafeCast} from "./libraries/SafeCast.sol";
import {Extsload} from "./Extsload.sol";
import {IStakingProtocol} from "./interfaces/IStakingProtocol.sol";

abstract contract LiquidityManager {
    using Buffer for Buffer.State;
    using SafeCast for *;
    using LiquidityBufferLibrary for LiquidityBuffer;
    using CurrencyLibrary for Currency;

    bytes32 internal constant _BUFFER_STORAGE_POSITION = keccak256("v4.core.LiquidityManager._buffers");

    function _setBuffer(Currency currency, LiquidityBuffer memory liquidityBuffer, IStakingProtocol stakingProtocol)
        internal
    {
        Buffer.State storage s = _buffer(currency);
        s.stakingProtocol = stakingProtocol;
        s.liquidityBuffer = liquidityBuffer;
    }

    function _buffer(Currency currency) private pure returns (Buffer.State storage s) {
        bytes32 position = keccak256(abi.encode(_BUFFER_STORAGE_POSITION, currency));
        assembly {
            s.slot := position
        }
    }

    function _doBuffer(Currency currency, int256 deltaAmount, address target) internal {
        if (deltaAmount == 0) return;
        Buffer.State storage s = _buffer(currency);
        (IStakingProtocol stakingProtocol, int256 releaseAmount) = s.doBuffer(currency, deltaAmount);
        if (releaseAmount > 0) {
            // release
            _delegateWithdraw(stakingProtocol, Currency.unwrap(currency), uint256(releaseAmount));
            unchecked {
                s.totalPrincipal -= uint256(releaseAmount);
            }
            _accountDelta(currency, deltaAmount.toInt128(), target);
        } else if (releaseAmount < 0) {
            _accountDelta(currency, deltaAmount.toInt128(), target);
            // deposit
            _delegateDeposit(stakingProtocol, Currency.unwrap(currency), uint256(-releaseAmount));
            unchecked {
                s.totalPrincipal += uint256(-releaseAmount);
            }
        } else {
            _accountDelta(currency, deltaAmount.toInt128(), target);
        }
    }

    function _delegateWithdraw(IStakingProtocol stakingProtocol, address currency, uint256 amount) internal {
        _delegateCall(
            address(stakingProtocol),
            abi.encodeWithSelector(IStakingProtocol.withdraw.selector, currency, address(this), amount)
        );
    }

    function _delegateDeposit(IStakingProtocol stakingProtocol, address currency, uint256 amount) internal {
        _delegateCall(
            address(stakingProtocol), abi.encodeWithSelector(IStakingProtocol.deposit.selector, currency, amount)
        );
    }

    function _delegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returnData) = target.delegatecall(data);
        if (!success) {
            assembly {
                let ptr := add(returnData, 0x20)
                let len := mload(returnData)
                revert(ptr, len)
            }
        }
        return returnData;
    }

    function _accountDelta(Currency currency, int128 delta, address target) internal virtual;
}
