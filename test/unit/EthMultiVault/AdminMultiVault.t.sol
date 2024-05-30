// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {EthMultiVault} from "../../../src/EthMultiVault.sol";
import {EthMultiVaultBase} from "../../EthMultiVaultBase.sol";
import {EthMultiVaultHelpers} from "../../helpers/EthMultiVaultHelpers.sol";
import {Errors} from "../../../src/libraries/Errors.sol";

contract AdminMultiVaultTest is EthMultiVaultBase, EthMultiVaultHelpers {
    function setUp() external {
        _setUp();
    }

    function testScheduleOperation() external {
        bytes32 operationId = keccak256("setAdmin");
        address newAdmin = address(0x123);
        bytes memory data = abi.encodeWithSelector(EthMultiVault.setAdmin.selector, newAdmin);
        uint256 minDelay = getMinDelay();

        // Expected operation hash
        bytes32 opHash = keccak256(abi.encodePacked(operationId, data, minDelay));

        // Schedule the operation
        vm.prank(msg.sender);
        ethMultiVault.scheduleOperation(operationId, data);

        // Check if the operation was scheduled correctly
        (bytes memory scheduledData, uint256 readyTime, bool executed) = ethMultiVault.timelocks(opHash);
        assertEq(scheduledData, data);
        assertEq(readyTime, block.timestamp + minDelay);
        assertFalse(executed);
    }

    function testCancelScheduledOperation() external {
        bytes32 operationId = keccak256("setExitFee");
        uint256 vaultId = 0;
        uint256 newExitFee = 100; // 100 basis points (1%)
        bytes memory data = abi.encodeWithSelector(EthMultiVault.setExitFee.selector, vaultId, newExitFee);
        uint256 minDelay = getMinDelay();

        // Schedule the operation
        vm.prank(msg.sender);
        ethMultiVault.scheduleOperation(operationId, data);

        // Cancel the scheduled operation
        vm.prank(msg.sender);
        ethMultiVault.cancelOperation(operationId, data);

        // Verify the operation is canceled
        bytes32 opHash = keccak256(abi.encodePacked(operationId, data, minDelay));
        ( , uint256 readyTime, bool executed) = ethMultiVault.timelocks(opHash);
        assertTrue(readyTime == 0 && !executed);
    }

    function testSetAdmin() external {
        bytes32 operationId = keccak256("setAdmin");
        address newAdmin = address(0x456);
        bytes memory data = abi.encodeWithSelector(EthMultiVault.setAdmin.selector, newAdmin);
        uint256 minDelay = getMinDelay();
        
        // Schedule the operation
        vm.prank(msg.sender);
        ethMultiVault.scheduleOperation(operationId, data);

        // Forward time to surpass the delay
        vm.warp(block.timestamp + minDelay + 1);

        // should revert if not admin
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(Errors.MultiVault_AdminOnly.selector));
        ethMultiVault.setAdmin(newAdmin);

        // Execute the scheduled operation
        vm.prank(msg.sender);
        ethMultiVault.setAdmin(newAdmin);

        // Verify the operation's effects
        address currentAdmin = getAdmin();
        assertEq(currentAdmin, newAdmin);

        // Verify the operation is marked as executed
        bytes32 opHash = keccak256(abi.encodePacked(operationId, data, minDelay));
        ( , , bool executed) = ethMultiVault.timelocks(opHash);
        assertTrue(executed);
    }

    function testSetProtocolVault() external {
        address testValue = bob;

        // msg.sender is the caller of EthMultiVaultBase
        vm.prank(msg.sender);
        ethMultiVault.setProtocolVault(testValue);
        assertEq(getProtocolVault(), testValue);
    }
    
    function testSetEntryFee() external {
        uint256 testVaultId = 0;
        uint256 testValue = 1000;

        // msg.sender is the caller of EthMultiVaultBase
        vm.prank(msg.sender);
        ethMultiVault.setEntryFee(testVaultId, testValue);
        assertEq(getEntryFee(testVaultId), testValue);
    }

    function testSetExitFee() external {
        bytes32 operationId = keccak256("setExitFee");
        uint256 vaultId = 0; // Example vault ID
        uint256 validExitFee = getFeeDenominator() / 20; // Valid exit fee within allowed range
        uint256 invalidExitFee = getFeeDenominator() / 5; // Invalid exit fee, exceeding allowed range
        uint256 minDelay = getMinDelay();
    
        // Schedule operation with a valid exit fee
        bytes memory validData = abi.encodeWithSelector(EthMultiVault.setExitFee.selector, vaultId, validExitFee);
        vm.prank(msg.sender);
        ethMultiVault.scheduleOperation(operationId, validData);

        // Schedule operation with an invalid exit fee
        bytes memory invalidData = abi.encodeWithSelector(EthMultiVault.setExitFee.selector, vaultId, invalidExitFee);
        vm.prank(msg.sender);
        ethMultiVault.scheduleOperation(operationId, invalidData);

        // Forward time to surpass the delay
        vm.warp(block.timestamp + minDelay + 1);

        // Attempt to set exit fee higher than allowed, should revert
        vm.prank(msg.sender);
        vm.expectRevert(abi.encodeWithSelector(Errors.MultiVault_InvalidExitFee.selector));
        ethMultiVault.setExitFee(vaultId, invalidExitFee);

        // Set a valid exit fee
        vm.prank(msg.sender);
        ethMultiVault.setExitFee(vaultId, validExitFee);

        // Verify the valid exit fee update
        uint256 currentExitFee = getExitFee(vaultId);
        assertEq(currentExitFee, validExitFee);

        // Verify the operation is marked as executed for the valid exit fee
        bytes32 opHashValid = keccak256(abi.encodePacked(operationId, validData, minDelay));
        (, , bool executedValid) = ethMultiVault.timelocks(opHashValid);
        assertTrue(executedValid);
    }


    function testSetProtocolFee() external {
        uint256 testVaultId = 0;
        uint256 testValue = 1000;

        // msg.sender is the caller of EthMultiVaultBase
        vm.prank(msg.sender);
        ethMultiVault.setProtocolFee(testVaultId, testValue);
        assertEq(getProtocolFee(testVaultId), testValue);
    }

    function testSetAtomShareLockFee() external {
        uint256 testValue = 1000;

        // msg.sender is the caller of EthMultiVaultBase
        vm.prank(msg.sender);
        ethMultiVault.setAtomShareLockFee(testValue);
        assertEq(getAtomShareLockFee(), testValue);
    }

    function testSetAtomCreationFee() external {
        uint256 testValue = 1000;

        // msg.sender is the caller of EthMultiVaultBase
        vm.prank(msg.sender);
        ethMultiVault.setAtomCreationFee(testValue);
        assertEq(getAtomCreationFee(), testValue);
    }

    function testSetTripleCreateFee() external {
        uint256 testValue = 1000;

        // msg.sender is the caller of EthMultiVaultBase
        vm.prank(msg.sender);
        ethMultiVault.setTripleCreationFee(testValue);
        assertEq(getTripleCreationFee(), testValue);
    }

    function testSetAtomDepositFraction() external {
        uint256 testValue = 1000;

        // msg.sender is the caller of EthMultiVaultBase
        vm.prank(msg.sender);
        ethMultiVault.setAtomDepositFraction(testValue);
        assertEq(getAtomDepositFraction(), testValue);
    }

    function testSetMinDeposit() external {
        uint256 testValue = 1000;

        // msg.sender is the caller of EthMultiVaultBase
        vm.prank(msg.sender);
        ethMultiVault.setMinDeposit(testValue);
        assertEq(getMinDeposit(), testValue);
    }

    function testSetMinShare() external {
        uint256 testValue = 1000;

        // msg.sender is the caller of EthMultiVaultBase
        vm.prank(msg.sender);
        ethMultiVault.setMinShare(testValue);
        assertEq(getMinShare(), testValue);
    }

    function testSetAtomUriMaxLength() external {
        uint256 testValue = 350;

        // msg.sender is the caller of EthMultiVaultBase
        vm.prank(msg.sender);
        ethMultiVault.setAtomUriMaxLength(testValue);
        assertEq(getAtomUriMaxLength(), testValue);
    }

    function getAtomCost()
        public
        view
        override
        returns (uint256)
    {
        return EthMultiVaultBase.getAtomCost();
    }
}
