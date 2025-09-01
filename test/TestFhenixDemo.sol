// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {FhenixDemo} from "../src/libraries/FhenixDemo.sol";

contract TestFhenixDemo is Test {
    
    function testFhenixDemo() public {
        // Test basic encryption
        FhenixDemo.euint256 memory encrypted = FhenixDemo.asEuint256(100);
        assertTrue(encrypted.initialized);
        assertEq(encrypted.value, 100);
        
        // Test addition
        FhenixDemo.euint256 memory a = FhenixDemo.asEuint256(50);
        FhenixDemo.euint256 memory b = FhenixDemo.asEuint256(30);
        FhenixDemo.euint256 memory sum = FhenixDemo.add(a, b);
        
        assertTrue(sum.initialized);
        assertEq(sum.value, 80);
    }
}
