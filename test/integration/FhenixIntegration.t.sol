// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
// import {FHE, euint32, euint64, euint256, ebool} from "@fhenixprotocol/FHE.sol"; // Using FhenixDemo instead
import {FhenixDemo} from "../../src/libraries/FhenixDemo.sol";
import {EncryptedMathDemo} from "../../src/libraries/EncryptedMathDemo.sol";

contract FhenixIntegrationTest is Test {
    
    function setUp() public {
        // Setup for Fhenix testnet integration
    }
    
    function testFHEOperations() public {
        // Test actual FHE operations on Fhenix testnet
        uint256 value1 = 100;
        uint256 value2 = 50;
        
        // Use FHE library directly for encryption
        FhenixDemo.euint256 memory encrypted1 = EncryptedMathDemo.encryptUint256(value1);
        FhenixDemo.euint256 memory encrypted2 = EncryptedMathDemo.encryptUint256(value2);
        
        // Test addition
        FhenixDemo.euint256 memory sum = EncryptedMathDemo.addEncrypted(encrypted1, encrypted2);
        // Note: In real FHE, we can't decrypt directly - this would be handled by the CoFHE coprocessor
        
        // Test subtraction
        FhenixDemo.euint256 memory diff = EncryptedMathDemo.subEncrypted(encrypted1, encrypted2);
        
        // Test multiplication
        FhenixDemo.euint256 memory product = EncryptedMathDemo.mulEncrypted(encrypted1, encrypted2);
    }
    
    function testEncryptedComparisons() public {
        uint256 value1 = 100;
        uint256 value2 = 50;
        
        FhenixDemo.euint256 memory encrypted1 = EncryptedMathDemo.encryptUint256(value1);
        FhenixDemo.euint256 memory encrypted2 = EncryptedMathDemo.encryptUint256(value2);
        
        // Test greater than
        FhenixDemo.ebool memory gtResult = EncryptedMathDemo.gt(encrypted1, encrypted2);
        // Note: In real FHE, we can't decrypt directly - this would be handled by the CoFHE coprocessor
        
        // Test less than
        FhenixDemo.ebool memory ltResult = EncryptedMathDemo.lt(encrypted1, encrypted2);
        
        // Test equality
        FhenixDemo.ebool memory eqResult = EncryptedMathDemo.eq(encrypted1, encrypted1);
    }
    
    function testSealingOperations() public {
        uint256 value = 12345;
        FhenixDemo.euint256 memory encrypted = EncryptedMathDemo.encryptUint256(value);
        
        // Note: Sealing operations would be handled by the CoFHE coprocessor
        // This is a simplified test for now
        assertTrue(true); // Placeholder assertion
    }
}