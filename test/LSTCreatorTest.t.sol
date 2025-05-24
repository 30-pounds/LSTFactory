// test/LSTCreatorTest.t.sol
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/LSTCreator.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "src/interfaces/vault/IVaultTokenized.sol";
import "test/mocks/MockToken.sol";
import "test/mocks/MockVaultTokenizedV2.sol";
import "test/mocks/MockDelegatorFactory.sol";
import "test/mocks/MockSlasherFactory.sol";

contract LSTCreatorTest is Test {
    LSTCreator public lstCreator;
    Token public mockToken;
    MockVaultTokenizedV2 public mockVault;
    MockDelegatorFactory public delegatorFactory;
    MockSlasherFactory public slasherFactory;
    address public user = address(1);

    function setUp() public {
        // Déployer les contrats de test
        mockToken = new Token();
        mockVault = new MockVaultTokenizedV2();
        delegatorFactory = new MockDelegatorFactory();
        slasherFactory = new MockSlasherFactory();
        
        // Déployer le LSTCreator
        lstCreator = new LSTCreator();
        
        // Donner des tokens au user
        mockToken.transfer(user, 1000 ether);
    }

    function testCreateLST() public {
        // Simuler l'appel depuis le user
        vm.startPrank(user);
        
        // Vérifier les adresses des contrats
        console.log("MockToken:", address(mockToken));
        console.log("MockVault:", address(mockVault));
        console.log("DelegatorFactory:", address(delegatorFactory));
        console.log("SlasherFactory:", address(slasherFactory));
        
        // Vérifier le solde de l'utilisateur
        console.log("User balance:", mockToken.balanceOf(user));
        
        try lstCreator.createLST(
            address(mockToken),    // Token de test
            1000000 ether,        // Limite initiale
            "Staked Test Token",  // Nom
            "sTEST",             // Symbole
            1 weeks              // Epoque
        ) returns (address collateral, address vault) {
            console.log("Collateral address:", collateral);
            console.log("Vault address:", vault);
            
            // Vérifier que les adresses sont non-nulles
            assertTrue(collateral != address(0), "Collateral should not be zero");
            assertTrue(vault != address(0), "Vault should not be zero");

            // Vérifier les propriétés du vault
            IVaultTokenized vaultContract = IVaultTokenized(vault);
            assertEq(vaultContract.collateral(), address(mockToken), "Wrong collateral address");
            assertEq(vaultContract.epochDuration(), 1 weeks, "Wrong epoch duration");
        } catch Error(string memory reason) {
            console.log("Test failed with reason:", reason);
            fail();
        } catch (bytes memory lowLevelData) {
            console.log("Test failed with low level error:", string(lowLevelData));
            console.log("Low level data length:", lowLevelData.length);
            fail();
        }

        vm.stopPrank();
    }

    function testStakeAndUnstake() public {
        vm.startPrank(user);
        
        try lstCreator.createLST(
            address(mockToken),
            1000000 ether,
            "Staked Test Token",
            "sTEST",
            1 weeks
        ) returns (address collateral, address vault) {
            // Approuver le vault pour dépenser les tokens
            mockToken.approve(vault, 100 ether);

            // Staker des tokens (dépôt pour le compte de l'utilisateur)
            try IVaultTokenized(vault).deposit(
                user,           // onBehalfOf: l'utilisateur reçoit les parts
                100 ether      // amount: montant à déposer
            ) returns (uint256 depositedAmount, uint256 mintedShares) {
                console.log("Deposit successful");
                console.log("Deposited amount:", depositedAmount);
                console.log("Minted shares:", mintedShares);
                
                // Vérifier le montant déposé et les parts reçues
                assertEq(depositedAmount, 100 ether, "Wrong deposited amount");
                assertEq(mintedShares, 100 ether, "Wrong minted shares");

                // Vérifier le solde actif
                assertEq(IVaultTokenized(vault).activeBalanceOf(user), 100 ether, "Wrong active balance");

                // Attendre la fin de l'époque
                vm.warp(block.timestamp + 1 weeks);

                // Retirer les tokens (l'utilisateur devra réclamer le retrait)
                try IVaultTokenized(vault).withdraw(
                    user,           // claimer: l'utilisateur devra réclamer le retrait
                    100 ether      // amount: montant à retirer
                ) returns (uint256 burnedShares, uint256 mintedWithdrawalShares) {
                    console.log("Withdraw successful");
                    console.log("Burned shares:", burnedShares);
                    console.log("Minted withdrawal shares:", mintedWithdrawalShares);
                    
                    // Vérifier les parts brûlées et les parts de retrait
                    assertEq(burnedShares, 100 ether, "Wrong burned shares");
                    assertEq(mintedWithdrawalShares, 100 ether, "Wrong withdrawal shares");

                    // Vérifier le solde final
                    assertEq(mockToken.balanceOf(user), 1000 ether, "Wrong final balance");
                } catch Error(string memory reason) {
                    console.log("Withdraw failed with reason:", reason);
                    fail();
                } catch (bytes memory lowLevelData) {
                    console.log("Withdraw failed with low level error:", string(lowLevelData));
                    console.log("Low level data length:", lowLevelData.length);
                    fail();
                }
            } catch Error(string memory reason) {
                console.log("Deposit failed with reason:", reason);
                fail();
            } catch (bytes memory lowLevelData) {
                console.log("Deposit failed with low level error:", string(lowLevelData));
                console.log("Low level data length:", lowLevelData.length);
                fail();
            }
        } catch Error(string memory reason) {
            console.log("CreateLST failed with reason:", reason);
            fail();
        } catch (bytes memory lowLevelData) {
            console.log("CreateLST failed with low level error:", string(lowLevelData));
            console.log("Low level data length:", lowLevelData.length);
            fail();
        }

        vm.stopPrank();
    }
}