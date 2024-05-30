// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {EthMultiVaultBase} from "../../EthMultiVaultBase.sol";
import {EthMultiVaultHelpers} from "../../helpers/EthMultiVaultHelpers.sol";
import {Errors} from "../../../src/libraries/Errors.sol";
import {LibZip} from "solady/utils/LibZip.sol";

contract CreateAtomCompressedTest is EthMultiVaultBase, EthMultiVaultHelpers {
    using LibZip for bytes;

    function setUp() external {
        _setUp();
    }

    function testCreateAtomCompressed() external {
        // prank call from alice
        // as both msg.sender and tx.origin
        vm.startPrank(alice, alice);

        // test values
        uint256 testAtomCost = getAtomCost();

        // snapshots before interaction
        uint256 totalAssetsBefore = vaultTotalAssets(ethMultiVault.count() + 1);
        uint256 totalSharesBefore = vaultTotalShares(ethMultiVault.count() + 1);
        uint256 protocolVaultBalanceBefore = address(getProtocolVault()).balance;

        // execute interaction - create atoms
        uint256 id1 = ethMultiVault.createAtom{value: testAtomCost}("atom1");

        // should have created a new atom vault
        assertEq(id1, ethMultiVault.count());

        checkDepositOnAtomVaultCreation(id1, testAtomCost, totalAssetsBefore, totalSharesBefore);

        checkProtocolVaultBalanceOnVaultCreation(id1, protocolVaultBalanceBefore);

        vm.stopPrank();
    }

    function testCreateAtomCompressedWithSameAtomData() external {
        // creating atoms with the same atom data should revert
        vm.startPrank(alice, alice);

        // test values
        uint256 testAtomCost = getAtomCost();

        uint256 id1 = ethMultiVault.createAtom{value: testAtomCost}("atom1");
        assertEq(id1, ethMultiVault.count());

        vm.expectRevert(abi.encodeWithSelector(Errors.MultiVault_AtomExists.selector, bytes("atom1")));
        ethMultiVault.createAtom{value: testAtomCost}("atom1");

        vm.stopPrank();
    }

    function testCreateAtomCompressedWithDifferentAtomData() external {
        vm.startPrank(alice, alice);

        uint256 id1 = ethMultiVault.createAtom{value: getAtomCost()}("atom1");
        assertEq(id1, ethMultiVault.count());

        uint256 id2 = ethMultiVault.createAtom{value: getAtomCost()}("atom2");
        assertEq(id2, ethMultiVault.count());

        vm.stopPrank();
    }

    function testCreateAtomInsufficientBalance() external {
        vm.startPrank(alice, alice);

        vm.expectRevert(abi.encodeWithSelector(Errors.MultiVault_InsufficientBalance.selector));
        ethMultiVault.createAtom("atom1");

        vm.stopPrank();
    }

    function getAtomCost() public view override returns (uint256) {
        return EthMultiVaultBase.getAtomCost();
    }
}
