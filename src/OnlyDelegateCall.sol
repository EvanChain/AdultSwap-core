// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract OnlyDelegateCall {
    error OnlyAllowDelegateCall();

    address internal immutable ADDRESS_SELF;

    /**
     * @notice Reverts if not called by delegatecall
     */
    modifier onlyDelegateCall() {
        if (address(this) == ADDRESS_SELF) revert OnlyAllowDelegateCall();
        _;
    }

    constructor() {
        ADDRESS_SELF = address(this);
    }
}
