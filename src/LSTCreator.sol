// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { contracts } from 'config/config_suzaku.sol';
import {IVaultTokenized} from "src/interfaces/IVaultTokenized.sol";
import {IDefaultCollateral} from "src/interfaces/IDefaultCollateral.sol";
import {IDefaultCollateralFactory} from "src/interfaces/IDefaultCollateralFactory.sol";

import {DefaultCollateral} from "src/DefaultCollateral.sol";

contract LSTCreator {
    address public immutable token;
    string public immutable name;
    string public immutable symbol;
    
    address public constant MiddlewareL1 = 0xbf9e863cF9F00f48D3Ed9D009515114365502569;
    address public constant CollateralFactory = 0x6441cA48f9d19E68e8AEb572De5c4836f8329903;
    address public constant VaultFactory = 0xC3b09a650c78daFb79e3C5B782402C8dc523fE88;
    address public constant SLASHER_FACTORY = 0x143e7fe257010A3855DFfacD5dC0BFBAb181b8f4;
    address public constant DELEGATOR_FACTORY = 0xC11D12ea4A2dcf67509A488585ff5120DccDceaA;

    constructor() {}

    function createLST(
        address token,
        uint256 initialLimit,
        string memory name,
        string memory symbol
    ) external returns (address collateral, address vault) {

        // 1. Create collateral for the L1 token
        address defaultCollateralAddress = IDefaultCollateralFactory(CollateralFactory).create(
            token,
            initialLimit
        );
        defaultCollateralToken = DefaultCollateral(defaultCollateralAddress);


        // 2. Create the vault associated
        uint64 lastVersion = VaultFactory.lastVersion();
        uint48 epochDuration = uint48(bound(epochDuration, 1, 50 weeks));
        address vaultAddress = VaultFactory.create(
            lastVersion,
            msg.sender,
            abi.encode(
                IVaultTokenized.InitParams({
                    collateral: address(collateral),
                    burner: address(0xdEaD),
                    epochDuration: epochDuration,
                    depositWhitelist: false,
                    isDepositLimit: false,
                    depositLimit: 0,
                    defaultAdminRoleHolder: msg.sender,
                    depositWhitelistSetRoleHolder: msg.sender,
                    depositorWhitelistRoleHolder: msg.sender,
                    isDepositLimitSetRoleHolder: msg.sender,
                    depositLimitSetRoleHolder: msg.sender,
                    name: name,
                    symbol: symbol
                })
            ),
            address(DelagatorFactory_contract),
            address(SlasherFactory_contract)
        );

        vault = VaultTokenized(vaultAddress);

        return (collateral, vault, lst);
    }
}

