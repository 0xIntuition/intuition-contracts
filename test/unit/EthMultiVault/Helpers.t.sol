// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {EthMultiVaultBase} from "../../EthMultiVaultBase.sol";
import {EthMultiVaultHelpers} from "../../helpers/EthMultiVaultHelpers.sol";
import {Errors} from "../../../src/libraries/Errors.sol";
import {Types} from "src/libraries/Types.sol";
import {AtomWallet} from "src/AtomWallet.sol";

contract HelpersTest is EthMultiVaultBase, EthMultiVaultHelpers {
    function setUp() external {
        _setUp();
    }

    function testMaxRedeem() external {
        // prank call from alice
        // as both msg.sender and tx.origin
        vm.startPrank(alice, alice);

        // test values
        uint256 testAtomCost = getAtomCost();
        uint256 testMinDesposit = getMinDeposit();
        uint256 testDespositAmount = testMinDesposit;

        // execute interaction - create atoms
        uint256 id = ethMultiVault.createAtom{value: testAtomCost}("atom1");

        // execute interaction - deposit atoms
        ethMultiVault.depositAtom{value: testDespositAmount}(alice, id);

        vm.stopPrank();

        /// @notice on vault creation all shares are minted to the caller's atom wallet
        address atomWallet = ethMultiVault.computeAtomWalletAddr(id);

        uint256 redeemableSharesAtomWallet = ethMultiVault.maxRedeem(atomWallet, id);
        uint256 redeemablesharesUser = ethMultiVault.maxRedeem(alice, id);

        assertEq(redeemableSharesAtomWallet + redeemablesharesUser + getMinShare(), vaultTotalShares(id));

        uint256 redeemablesharesFromUserWithNoDeposits = ethMultiVault.maxRedeem(bob, id);
        assertEq(redeemablesharesFromUserWithNoDeposits, 0);
    }

    function testDeployAtomWallet() external {
        // test values
        uint256 atomId = 1;

        // should not be able to deploy atom wallet for atom that has not been created yet
        vm.expectRevert(
            abi.encodeWithSelector(Errors.MultiVault_VaultDoesNotExist.selector)
        );
        // execute interaction - deploy atom wallet
        ethMultiVault.deployAtomWallet(atomId);

        // execute interaction - create atom
        ethMultiVault.createAtom{value: getAtomCost()}("atom1");

        address atomWalletAddress = ethMultiVault.deployAtomWallet(atomId);
        address payable atomWallet = payable(atomWalletAddress);

        address computedAddress = ethMultiVault.computeAtomWalletAddr(atomId);

        // verify the returned atomWallet address is not zero
        assertNotEq(atomWallet, address(0));

        // verify atomWallet is a contract
        assertTrue(isContract(atomWallet));

        // verify the computed address matches the actual wallet address
        assertEq(computedAddress, atomWalletAddress);
    }

    function testPlainEtherTransferToContractShouldRevert() external {
        // prank call from alice
        // as both msg.sender and tx.origin
        vm.startPrank(alice, alice);

        // should revert if plain ether transfer is attempted
        vm.expectRevert(
            abi.encodeWithSelector(Errors.MultiVault_ReceiveNotAllowed.selector)
        );
        payable(address(ethMultiVault)).transfer(1 ether);

        vm.stopPrank();
    }

    function isContract(address _addr) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function getAtomCost() public view override returns (uint256) {
        return EthMultiVaultBase.getAtomCost();
    }
}
