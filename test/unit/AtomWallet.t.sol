// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {EthMultiVaultBase} from "../EthMultiVaultBase.sol";

contract AtomWalletTest is EthMultiVaultBase {
    function setUp() external {
        _setUp();
    }
}
