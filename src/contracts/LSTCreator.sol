// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;




import {IVaultTokenized} from "src/interfaces/vault/IVaultTokenized.sol";
import {IVaultTokenized} from "src/interfaces/vault/IVaultFactory.sol";
import {IL1RestakeDelegator} from "src/interfaces/delegator/IL1RestakeDelegator.sol";
import {IDefaultCollateral} from "src/interfaces/IDefaultCollateral.sol";
import {IDefaultCollateralFactory} from "src/interfaces/IDefaultCollateralFactory.sol";

import {DefaultCollateral} from "src/contracts/DefaultCollateral.sol";
import {L1RestakeDelegator} from "src/contracts/L1RestakeDelegator.sol";

contract LSTCreator {
    address public immutable token;
    string public immutable name;
    string public immutable symbol;
    
    address public constant MiddlewareL1 = 0xbf9e863cF9F00f48D3Ed9D009515114365502569;
    address public constant CollateralFactory = 0x6441cA48f9d19E68e8AEb572De5c4836f8329903;
    address public constant VaultFactory = 0xC3b09a650c78daFb79e3C5B782402C8dc523fE88;
    address public constant SLASHER_FACTORY = 0x143e7fe257010A3855DFfacD5dC0BFBAb181b8f4;
    address public constant delegatorFactory = 0xC11D12ea4A2dcf67509A488585ff5120DccDceaA;
    address public constant operatorRegistry = 0x46D45D6be6214F6bd8124187caD1a5302755d7A2;
    address public constant operatorL1OptInService = 0x0360C1cB32A20D97b358538D9Db71339ce2c9592;
    address public constant validatorManagerAddress = 0x84F2B4D4cF8DA889701fBe83d127896880c04325;
    address public constant l1Registry = 0xB9826Bbf0deB10cC3924449B93F418db6b16be36;

    

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
        uint64 lastVersion = IVaultFactory(VaultFactory).lastVersion();
        uint48 epochDuration = uint48(bound(epochDuration, 1, 50 weeks));
        address vaultAddress = IVaultFactory(VaultFactory).create(
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

        // 3. Create the delegator
        address[] memory l1LimitSetRoleHolders = new address[](1);
        l1LimitSetRoleHolders[0] = msg.sender;
        address[] memory operatorL1SharesSetRoleHolders = new address[](1);
        operatorL1SharesSetRoleHolders[0] = msg.sender;

        address delegatorAddress = delegatorFactory.create(
            0,
            abi.encode(
                address(vault),
                abi.encode(
                    IL1RestakeDelegator.InitParams({
                        baseParams: IBaseDelegator.BaseParams({
                            defaultAdminRoleHolder: msg.sender,
                            hook: address(0),
                            hookSetRoleHolder: msg.sender
                        }),
                        l1LimitSetRoleHolders: l1LimitSetRoleHolders,
                        operatorL1SharesSetRoleHolders: operatorL1SharesSetRoleHolders
                    })
                )
            )
        );

        delegator = L1RestakeDelegator(delegatorAddress);

        vault.setDelegator(delegatorAddress);

        // 4. Register the L1
        l1Registry.registerL1{value: 0.01 ether}(_l1, _middleware, "metadataURL");

        return (collateral, vault);
    }
}

