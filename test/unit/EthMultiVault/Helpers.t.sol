// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.21;

import "forge-std/Test.sol";
import {EthMultiVaultBase} from "../../EthMultiVaultBase.sol";
import {EthMultiVaultHelpers} from "../../helpers/EthMultiVaultHelpers.sol";
import {Errors} from "../../../src/libraries/Errors.sol";
import {AtomWallet} from "src/AtomWallet.sol";
import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

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
        uint256 testDepositAmount = testMinDesposit;

        // execute interaction - create atoms
        uint256 id = ethMultiVault.createAtom{value: testAtomCost}("atom1");

        // execute interaction - deposit atoms
        ethMultiVault.depositAtom{value: testDepositAmount}(alice, id);

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
        vm.expectRevert(abi.encodeWithSelector(Errors.MultiVault_VaultDoesNotExist.selector));
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

    function testAtomWalletOwnershipClaim() external {
        // execute interaction - create atom
        uint256 atomId = ethMultiVault.createAtom{value: getAtomCost()}("atom1");

        address atomWalletAddress = ethMultiVault.deployAtomWallet(atomId);
        address payable atomWallet = payable(atomWalletAddress);

        (, bytes memory returnData1) = atomWallet.call(abi.encodeWithSelector(AtomWallet.owner.selector));

        address atomWalletOwner = abi.decode(returnData1, (address));
        address atomWarden = ethMultiVault.getAtomWarden();

        assertEq(atomWalletOwner, atomWarden);

        vm.startPrank(atomWarden, atomWarden);

        (bool success,) = atomWallet.call(abi.encodeWithSelector(AtomWallet.transferOwnership.selector, address(0xabc)));
        assertEq(success, true);

        (, bytes memory returnData2) = atomWallet.call(abi.encodeWithSelector(AtomWallet.owner.selector));

        address newOwner = abi.decode(returnData2, (address));

        assertEq(newOwner, address(0xabc));

        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableInvalidOwner.selector));

        (bool success2,) =
            atomWallet.call(abi.encodeWithSelector(AtomWallet.transferOwnership.selector, address(0x456)));
        assertEq(success2, false);

        vm.stopPrank();

        // msg.sender = admin
        vm.startPrank(msg.sender, msg.sender);

        ethMultiVault.setAtomWarden(address(0xdef));

        (, bytes memory returnData3) = atomWallet.call(abi.encodeWithSelector(AtomWallet.owner.selector));

        address atomWalletOwnerAfterUpdate = abi.decode(returnData3, (address));

        // Changing the atomWarden should not affect the ownership of the atom wallet if it has been claimed
        assertEq(atomWalletOwnerAfterUpdate, address(0xabc));

        address atomWardenAfterUpdate = ethMultiVault.getAtomWarden();

        assertEq(atomWardenAfterUpdate, address(0xdef));

        vm.stopPrank();
    }

    function testPlainEtherTransferToContractShouldRevert() external {
        // prank call from alice
        // as both msg.sender and tx.origin
        vm.startPrank(alice, alice);

        // should revert if plain ether transfer is attempted
        vm.expectRevert(abi.encodeWithSelector(Errors.MultiVault_ReceiveNotAllowed.selector));
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
