// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IVaultTokenized} from "src/interfaces/vault/IVaultTokenized.sol";
import {IVaultFactory} from "src/interfaces/vault/IVaultFactory.sol";
import {IL1RestakeDelegator} from "src/interfaces/delegator/IL1RestakeDelegator.sol";
import {IDefaultCollateral} from "src/interfaces/IDefaultCollateral.sol";
import {IDefaultCollateralFactory} from "src/interfaces/IDefaultCollateralFactory.sol";
import {IDelegatorFactory} from "src/interfaces/IDelegatorFactory.sol";
import {IL1Registry} from "src/interfaces/IL1Registry.sol";
import {IBaseDelegator} from "src/interfaces/delegator/IBaseDelegator.sol";

contract LSTCreator {
    // Contract addresses
    address public constant MIDDLEWARE_L1 = 0xbf9e863cF9F00f48D3Ed9D009515114365502569;
    address public constant COLLATERAL_FACTORY = 0x6441cA48f9d19E68e8AEb572De5c4836f8329903;
    address public constant VAULT_FACTORY = 0xC3b09a650c78daFb79e3C5B782402C8dc523fE88;
    address public constant SLASHER_FACTORY = 0x143e7fe257010A3855DFfacD5dC0BFBAb181b8f4;
    address public constant DELEGATOR_FACTORY = 0xC11D12ea4A2dcf67509A488585ff5120DccDceaA;
    address public constant OPERATOR_REGISTRY = 0x46D45D6be6214F6bd8124187caD1a5302755d7A2;
    address public constant OPERATOR_L1_OPT_IN_SERVICE = 0x0360C1cB32A20D97b358538D9Db71339ce2c9592;
    address public constant VALIDATOR_MANAGER = 0x84F2B4D4cF8DA889701fBe83d127896880c04325;
    address public constant L1_REGISTRY = 0xB9826Bbf0deB10cC3924449B93F418db6b16be36;

    constructor() {}

    function createLST(
        address _token,
        uint256 initialLimit,
        string memory _name,
        string memory _symbol,
        uint48 _epochDuration

    ) external {
        // 1. Create collateral for the L1 token
        address collateral = IDefaultCollateralFactory(COLLATERAL_FACTORY).create(
            _token,
            initialLimit,
            msg.sender
        );

//        // 2. Create the vault
//        uint64 lastVersion = IVaultFactory(VAULT_FACTORY).lastVersion();
//        
//        // Ensure epochDuration is between 1 and 50 weeks
//        require(_epochDuration >= 1 weeks && _epochDuration <= 50 weeks, "Invalid epoch duration");
//        
//        address vaultAddress = IVaultFactory(VAULT_FACTORY).create(
//            lastVersion,
//            msg.sender,
//            abi.encode(
//                IVaultTokenized.InitParams({
//                    collateral: collateral,
//                    burner: address(0xdEaD),
//                    epochDuration: _epochDuration,
//                    depositWhitelist: false,
//                    isDepositLimit: false,
//                    depositLimit: 0,
//                    defaultAdminRoleHolder: msg.sender,
//                    depositWhitelistSetRoleHolder: msg.sender,
//                    depositorWhitelistRoleHolder: msg.sender,
//                    isDepositLimitSetRoleHolder: msg.sender,
//                    depositLimitSetRoleHolder: msg.sender,
//                    name: _name,
//                    symbol: _symbol
//                })
//            ),
//            DELEGATOR_FACTORY,
//            SLASHER_FACTORY
//        );
//
//        vault = vaultAddress;
//
//        // 3. Create the delegator
//        address[] memory l1LimitSetRoleHolders = new address[](1);
//        l1LimitSetRoleHolders[0] = msg.sender;
//        address[] memory operatorL1SharesSetRoleHolders = new address[](1);
//        operatorL1SharesSetRoleHolders[0] = msg.sender;
//
//        address delegatorAddress = IDelegatorFactory(DELEGATOR_FACTORY).create(
//            0,
//            abi.encode(
//                address(vault),
//                abi.encode(
//                    IL1RestakeDelegator.InitParams({
//                        baseParams: IBaseDelegator.BaseParams({
//                            defaultAdminRoleHolder: msg.sender,
//                            hook: address(0),
//                            hookSetRoleHolder: msg.sender
//                        }),
//                        l1LimitSetRoleHolders: l1LimitSetRoleHolders,
//                        operatorL1SharesSetRoleHolders: operatorL1SharesSetRoleHolders
//                    })
//                )
//            )
//        );
//
//        // 4. Set delegator in vault
//        IVaultTokenized(vault).setDelegator(delegatorAddress);
//
    }
}

