// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStakingProtocol {
    function totalAssets() external view returns (uint256);

    function asset() external view returns (address);

    function deposit(uint256 amount) external payable;

    function withdraw(address to, uint256 amount) external;
}
