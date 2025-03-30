// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStakingProtocol {
    function totalAssets(address asset) external view returns (uint256);

    function deposit(address asset, uint256 amount) external payable;

    function withdraw(address asset, address to, uint256 amount) external;
}
