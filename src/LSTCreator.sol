// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { contracts } from './config/config_suzaku';
import {IVaultTokenized} from "interfaces/IVaultTokenized.sol";

contract LSTCreator {
    address public immutable token;
    string public immutable name;
    string public immutable symbol;
    
    // Suzaku contracts
    address public immutable MiddlewareL1_contract;
    address public immutable CollateralFactory_contract;
    address public immutable VaultFactory_contract;
    address public immutable SlasherFactory_contract;
    address public immutable DelegatorFactory_contract;

    constructor() {
        // Initialize contracts
        MiddlewareL1_contract = contracts.MiddlewareL1_contract;
        CollateralFactory_contract = contracts.CollateralFactory_contract;
        VaultFactory_contract = contracts.VaultFactory_contract;
        SlasherFactory_contract = 0x143e7fe257010A3855DFfacD5dC0BFBAb181b8f4;
        DelegatorFactory_contract = 0xC11D12ea4A2dcf67509A488585ff5120DccDceaA;
    }

    function createLST(
        address token,
        uint256 initialLimit,
        string memory name,
        string memory symbol,
    ) external returns (address collateral, address vault) {

        // 1. Create collateral for the L1 token
        collateral = CollateralFactory_contract.create(
            token,
            initialLimit
        );
        

        // 2. Create the vault associated
        uint64 lastVersion = VaultFactory_contract.lastVersion();
        uint48 epochDuration = uint48(bound(epochDuration, 1, 50 weeks));
        address vaultAddress = VaultFactory_contract.create(
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
                    name: {name},
                    symbol: {symbol}
                })
            ),
            address(DelagatorFactory_contract),
            address(SlasherFactory_contract)
        );

        vault = VaultTokenized(vaultAddress);



        // 3. Register vault in middleware
        IMiddlewareL1(MiddlewareL1_contract).registerVault(vault);

        return (collateral, vault, lst);
    }
}

