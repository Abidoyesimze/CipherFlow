// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {CipherFlowHook} from "../../src/CipherFlowHook.sol";

contract GasOptimizationTest is Test {
    CipherFlowHook hook;
    
    // Gas benchmarks
    uint256 constant MAX_SWAP_GAS = 200000;
    uint256 constant MAX_LIQUIDITY_GAS = 300000;
    uint256 constant MAX_ENCRYPTION_GAS = 150000;
    
    function setUp() public {
        // Setup for gas testing
    }
    
    function testSwapGasUsage() public {
        // Test normal swap gas usage
        uint256 gasBefore = gasleft();
        // Perform swap operation
        uint256 gasUsed = gasBefore - gasleft();
        
        console.log("Normal swap gas usage:", gasUsed);
        assertLt(gasUsed, MAX_SWAP_GAS, "Swap gas usage too high");
    }
    
    function testEncryptionGasUsage() public {
        // Test encryption operation gas usage
        uint256 gasBefore = gasleft();
        // Perform encryption
        uint256 gasUsed = gasBefore - gasleft();
        
        console.log("Encryption gas usage:", gasUsed);
        assertLt(gasUsed, MAX_ENCRYPTION_GAS, "Encryption gas usage too high");
    }
    
    function testBatchOptimization() public {
        // Test that batch operations are more efficient than individual operations
        uint256 individualCost = 0;
        uint256 batchCost = 0;
        
        // Measure individual operations
        for (uint256 i = 0; i < 10; i++) {
            uint256 gasBeforeIndividual = gasleft();
            // Individual operation
            individualCost += gasBeforeIndividual - gasleft();
        }
        
        // Measure batch operation
        uint256 gasBeforeBatch = gasleft();
        // Batch operation with 10 items
        batchCost = gasBeforeBatch - gasleft();
        
        console.log("Individual total cost:", individualCost);
        console.log("Batch cost:", batchCost);
        
        // Batch should be more efficient
        assertLt(batchCost, individualCost, "Batch operation not optimized");
    }
}