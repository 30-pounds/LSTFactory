// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract ConfigSuzaku {
    // Contract addresses
    address public constant MIDDLEWARE_L1 = 0xbf9e863cF9F00f48D3Ed9D009515114365502569;
    address public constant COLLATERAL_FACTORY = 0x6441cA48f9d19E68e8AEb572De5c4836f8329903;
    address public constant VAULT_FACTORY = 0xC3b09a650c78daFb79e3C5B782402C8dc523fE88;
    address public constant SLASHER_FACTORY = 0x143e7fe257010A3855DFfacD5dC0BFBAb181b8f4;
    address public constant DELEGATOR_FACTORY = 0xC11D12ea4A2dcf67509A488585ff5120DccDceaA;

    // RPC URL for Avalanche Fuji testnet
    string public constant RPC_URL = "https://api.avax-test.network/ext/bc/C/rpc";

    // Function to get all contract addresses
    function getContracts() external pure returns (
        address middlewareL1,
        address collateralFactory,
        address vaultFactory,
        address slasherFactory,
        address delegatorFactory
    ) {
        return (
            MIDDLEWARE_L1,
            COLLATERAL_FACTORY,
            VAULT_FACTORY,
            SLASHER_FACTORY,
            DELEGATOR_FACTORY
        );
    }
}