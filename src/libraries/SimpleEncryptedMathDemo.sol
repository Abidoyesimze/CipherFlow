// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {FhenixDemo} from "./FhenixDemo.sol";

/**
 * @title SimpleEncryptedMathDemo
 * @notice Simplified demo library for encrypted mathematical operations
 * @dev Uses only the available functions from FhenixDemo
 */
library SimpleEncryptedMathDemo {
    
    error InvalidEncryptedData();
    error ComputationFailed();

    // ==================== ENCRYPTION FUNCTIONS ====================
    
    /**
     * @notice Encrypt uint256 value
     */
    function encryptUint256(uint256 value) internal pure returns (FhenixDemo.euint256 memory) {
        return FhenixDemo.asEuint256(value);
    }
    
    /**
     * @notice Encrypt uint32 value
     */
    function encryptUint32(uint32 value) internal pure returns (FhenixDemo.euint32 memory) {
        return FhenixDemo.asEuint32(value);
    }
    
    /**
     * @notice Encrypt uint64 value
     */
    function encryptUint64(uint64 value) internal pure returns (FhenixDemo.euint64 memory) {
        return FhenixDemo.asEuint64(value);
    }

    // ==================== ARITHMETIC OPERATIONS ====================
    
    /**
     * @notice Add two encrypted uint256 values
     */
    function addEncrypted(FhenixDemo.euint256 memory a, FhenixDemo.euint256 memory b) internal pure returns (FhenixDemo.euint256 memory) {
        return FhenixDemo.add(a, b);
    }
    
    /**
     * @notice Add two encrypted uint32 values
     */
    function addEncrypted(FhenixDemo.euint32 memory a, FhenixDemo.euint32 memory b) internal pure returns (FhenixDemo.euint32 memory) {
        return FhenixDemo.add(a, b);
    }
    
    /**
     * @notice Subtract two encrypted uint256 values
     */
    function subEncrypted(FhenixDemo.euint256 memory a, FhenixDemo.euint256 memory b) internal pure returns (FhenixDemo.euint256 memory) {
        return FhenixDemo.sub(a, b);
    }
    
    /**
     * @notice Subtract two encrypted uint32 values
     */
    function subEncrypted(FhenixDemo.euint32 memory a, FhenixDemo.euint32 memory b) internal pure returns (FhenixDemo.euint32 memory) {
        return FhenixDemo.sub(a, b);
    }
    
    /**
     * @notice Multiply two encrypted uint256 values
     */
    function mulEncrypted(FhenixDemo.euint256 memory a, FhenixDemo.euint256 memory b) internal pure returns (FhenixDemo.euint256 memory) {
        return FhenixDemo.mul(a, b);
    }
    
    /**
     * @notice Multiply two encrypted uint32 values
     */
    function mulEncrypted(FhenixDemo.euint32 memory a, FhenixDemo.euint32 memory b) internal pure returns (FhenixDemo.euint32 memory) {
        return FhenixDemo.mul(a, b);
    }
    
    /**
     * @notice Compare two encrypted uint256 values (greater than)
     */
    function gt(FhenixDemo.euint256 memory a, FhenixDemo.euint256 memory b) internal pure returns (FhenixDemo.ebool memory) {
        return FhenixDemo.gt(a, b);
    }
    
    /**
     * @notice Compare two encrypted uint32 values (greater than)
     */
    function gt(FhenixDemo.euint32 memory a, FhenixDemo.euint32 memory b) internal pure returns (FhenixDemo.ebool memory) {
        return FhenixDemo.gt(a, b);
    }
    
    /**
     * @notice Compare two encrypted uint256 values (less than)
     */
    function lt(FhenixDemo.euint256 memory a, FhenixDemo.euint256 memory b) internal pure returns (FhenixDemo.ebool memory) {
        return FhenixDemo.lt(a, b);
    }
    
    /**
     * @notice Compare two encrypted uint32 values (less than)
     */
    function lt(FhenixDemo.euint32 memory a, FhenixDemo.euint32 memory b) internal pure returns (FhenixDemo.ebool memory) {
        return FhenixDemo.lt(a, b);
    }
    
    /**
     * @notice Compare two encrypted uint256 values for equality
     */
    function eq(FhenixDemo.euint256 memory a, FhenixDemo.euint256 memory b) internal pure returns (FhenixDemo.ebool memory) {
        return FhenixDemo.eq(a, b);
    }
    
    /**
     * @notice Compare two encrypted uint32 values for equality
     */
    function eq(FhenixDemo.euint32 memory a, FhenixDemo.euint32 memory b) internal pure returns (FhenixDemo.ebool memory) {
        return FhenixDemo.eq(a, b);
    }

    // ==================== SEALING FUNCTIONS ====================
    
    /**
     * @notice Seal encrypted data for specific user
     */
    function seal(FhenixDemo.euint256 memory data, bytes32 publicKey) internal pure returns (bytes memory) {
        return FhenixDemo.seal(data, publicKey);
    }
    
    /**
     * @notice Seal encrypted data for specific user
     */
    function seal(FhenixDemo.euint32 memory data, bytes32 publicKey) internal pure returns (bytes memory) {
        return FhenixDemo.seal(data, publicKey);
    }
    
    /**
     * @notice Seal encrypted data for specific user
     */
    function seal(FhenixDemo.euint64 memory data, bytes32 publicKey) internal pure returns (bytes memory) {
        return FhenixDemo.seal(data, publicKey);
    }
}
