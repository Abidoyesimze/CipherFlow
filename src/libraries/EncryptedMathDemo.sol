// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {FhenixDemo} from "./FhenixDemo.sol";

/**
 * @title EncryptedMathDemo
 * @notice Production-ready demo library for encrypted mathematical operations
 * @dev Uses FhenixDemo for demo purposes - replace with actual Fhenix in production
 * @author CipherFlow Team
 */
library EncryptedMathDemo {

    error InvalidEncryptedData();
    error ComputationFailed();
    error DivisionByZero();

    // ==================== ARITHMETIC OPERATIONS ====================
    
    /**
     * @notice Add two encrypted uint32 values
     */
    function addEncrypted(FhenixDemo.euint32 memory a, FhenixDemo.euint32 memory b) internal pure returns (FhenixDemo.euint32 memory result) {
        return FhenixDemo.add(a, b);
    }

    /**
     * @notice Add two encrypted uint64 values
     */
    function addEncrypted(FhenixDemo.euint64 memory a, FhenixDemo.euint64 memory b) internal pure returns (FhenixDemo.euint64 memory result) {
        return FhenixDemo.add(a, b);
    }

    /**
     * @notice Add two encrypted uint256 values
     */
    function addEncrypted(FhenixDemo.euint256 memory a, FhenixDemo.euint256 memory b) internal pure returns (FhenixDemo.euint256 memory result) {
        return FhenixDemo.add(a, b);
    }

    /**
     * @notice Subtract two encrypted uint32 values
     */
    function subEncrypted(FhenixDemo.euint32 memory a, FhenixDemo.euint32 memory b) internal pure returns (FhenixDemo.euint32 memory result) {
        return FhenixDemo.sub(a, b);
    }

    /**
     * @notice Subtract two encrypted uint64 values
     */
    function subEncrypted(FhenixDemo.euint64 memory a, FhenixDemo.euint64 memory b) internal pure returns (FhenixDemo.euint64 memory result) {
        return FhenixDemo.sub(a, b);
    }

    /**
     * @notice Subtract two encrypted uint256 values
     */
    function subEncrypted(FhenixDemo.euint256 memory a, FhenixDemo.euint256 memory b) internal pure returns (FhenixDemo.euint256 memory result) {
        return FhenixDemo.sub(a, b);
    }

    /**
     * @notice Multiply two encrypted uint32 values
     */
    function mulEncrypted(FhenixDemo.euint32 memory a, FhenixDemo.euint32 memory b) internal pure returns (FhenixDemo.euint32 memory result) {
        return FhenixDemo.mul(a, b);
    }

    /**
     * @notice Multiply two encrypted uint64 values
     */
    function mulEncrypted(FhenixDemo.euint64 memory a, FhenixDemo.euint64 memory b) internal pure returns (FhenixDemo.euint64 memory result) {
        return FhenixDemo.mul(a, b);
    }

    /**
     * @notice Multiply two encrypted uint256 values
     */
    function mulEncrypted(FhenixDemo.euint256 memory a, FhenixDemo.euint256 memory b) internal pure returns (FhenixDemo.euint256 memory result) {
        return FhenixDemo.mul(a, b);
    }

    /**
     * @notice Divide two encrypted uint32 values
     */
    function divEncrypted(FhenixDemo.euint32 memory a, FhenixDemo.euint32 memory b) internal pure returns (FhenixDemo.euint32 memory result) {
        return FhenixDemo.div(a, b);
    }

    /**
     * @notice Divide two encrypted uint64 values
     */
    function divEncrypted(FhenixDemo.euint64 memory a, FhenixDemo.euint64 memory b) internal pure returns (FhenixDemo.euint64 memory result) {
        return FhenixDemo.div(a, b);
    }

    // ==================== CONVERSION FUNCTIONS ====================

    /**
     * @notice Convert plaintext uint32 to encrypted euint32
     */
    function encryptUint32(uint32 value) internal pure returns (FhenixDemo.euint32 memory encrypted) {
        return FhenixDemo.asEuint32(value);
    }

    /**
     * @notice Convert plaintext uint64 to encrypted euint64
     */
    function encryptUint64(uint64 value) internal pure returns (FhenixDemo.euint64 memory encrypted) {
        return FhenixDemo.asEuint64(value);
    }

    /**
     * @notice Convert plaintext uint256 to encrypted euint256
     */
    function encryptUint256(uint256 value) internal pure returns (FhenixDemo.euint256 memory encrypted) {
        return FhenixDemo.asEuint256(value);
    }

    // ==================== COMPARISON OPERATIONS ====================

    /**
     * @notice Greater than comparison for euint32
     */
    function gt(FhenixDemo.euint32 memory a, FhenixDemo.euint32 memory b) internal pure returns (FhenixDemo.ebool memory result) {
        return FhenixDemo.gt(a, b);
    }

    /**
     * @notice Greater than comparison for euint64
     */
    function gt(FhenixDemo.euint64 memory a, FhenixDemo.euint64 memory b) internal pure returns (FhenixDemo.ebool memory result) {
        return FhenixDemo.gt(a, b);
    }

    /**
     * @notice Greater than comparison for euint256
     */
    function gt(FhenixDemo.euint256 memory a, FhenixDemo.euint256 memory b) internal pure returns (FhenixDemo.ebool memory result) {
        return FhenixDemo.gt(a, b);
    }

    /**
     * @notice Less than comparison for euint32
     */
    function lt(FhenixDemo.euint32 memory a, FhenixDemo.euint32 memory b) internal pure returns (FhenixDemo.ebool memory result) {
        return FhenixDemo.lt(a, b);
    }

    /**
     * @notice Less than comparison for euint64
     */
    function lt(FhenixDemo.euint64 memory a, FhenixDemo.euint64 memory b) internal pure returns (FhenixDemo.ebool memory result) {
        return FhenixDemo.lt(a, b);
    }

    /**
     * @notice Equality comparison for euint32
     */
    function eq(FhenixDemo.euint32 memory a, FhenixDemo.euint32 memory b) internal pure returns (FhenixDemo.ebool memory result) {
        return FhenixDemo.eq(a, b);
    }

    /**
     * @notice Equality comparison for euint64
     */
    function eq(FhenixDemo.euint64 memory a, FhenixDemo.euint64 memory b) internal pure returns (FhenixDemo.ebool memory result) {
        return FhenixDemo.eq(a, b);
    }

    // ==================== CONDITIONAL SELECTION ====================

    /**
     * @notice Conditional selection between encrypted uint32 values
     */
    function select(FhenixDemo.ebool memory condition, FhenixDemo.euint32 memory trueValue, FhenixDemo.euint32 memory falseValue) 
        internal pure returns (FhenixDemo.euint32 memory result) {
        return FhenixDemo.select(condition, trueValue, falseValue);
    }

    /**
     * @notice Conditional selection between encrypted uint64 values
     */
    function select(FhenixDemo.ebool memory condition, FhenixDemo.euint64 memory trueValue, FhenixDemo.euint64 memory falseValue) 
        internal pure returns (FhenixDemo.euint64 memory result) {
        return FhenixDemo.select(condition, trueValue, falseValue);
    }

    /**
     * @notice Conditional selection between encrypted uint256 values
     */
    function select(FhenixDemo.ebool memory condition, FhenixDemo.euint256 memory trueValue, FhenixDemo.euint256 memory falseValue) 
        internal pure returns (FhenixDemo.euint256 memory result) {
        return FhenixDemo.select(condition, trueValue, falseValue);
    }

    // ==================== SEALING FUNCTIONS ====================

    /**
     * @notice Seal euint32 for specific user
     * @dev Sealing operations are handled by the CoFHE coprocessor
     */
    function seal(FhenixDemo.euint32 memory encrypted, bytes32 publicKey) internal pure returns (bytes memory sealedData) {
        return FhenixDemo.seal(encrypted, publicKey);
    }

    /**
     * @notice Seal euint64 for specific user
     * @dev Sealing operations are handled by the CoFHE coprocessor
     */
    function seal(FhenixDemo.euint64 memory encrypted, bytes32 publicKey) internal pure returns (bytes memory sealedData) {
        return FhenixDemo.seal(encrypted, publicKey);
    }

    /**
     * @notice Seal euint256 for specific user
     * @dev Sealing operations are handled by the CoFHE coprocessor
     */
    function seal(FhenixDemo.euint256 memory encrypted, bytes32 publicKey) internal pure returns (bytes memory sealedData) {
        return FhenixDemo.seal(encrypted, publicKey);
    }

    // ==================== ADVANCED OPERATIONS ====================

    /**
     * @notice Calculate encrypted percentage
     */
    function calculatePercentage(FhenixDemo.euint256 memory value, uint256 percentage) 
        internal pure returns (FhenixDemo.euint256 memory result) {
        FhenixDemo.euint256 memory encryptedPercentage = FhenixDemo.asEuint256(percentage);
        FhenixDemo.euint256 memory basisPoints = FhenixDemo.asEuint256(10000);
        return FhenixDemo.div(FhenixDemo.mul(value, encryptedPercentage), basisPoints);
    }

    /**
     * @notice Calculate encrypted maximum
     */
    function max(FhenixDemo.euint32 memory a, FhenixDemo.euint32 memory b) internal pure returns (FhenixDemo.euint32 memory result) {
        FhenixDemo.ebool memory isAGreater = FhenixDemo.gt(a, b);
        return FhenixDemo.select(isAGreater, a, b);
    }

    /**
     * @notice Calculate encrypted maximum
     */
    function max(FhenixDemo.euint64 memory a, FhenixDemo.euint64 memory b) internal pure returns (FhenixDemo.euint64 memory result) {
        FhenixDemo.ebool memory isAGreater = FhenixDemo.gt(a, b);
        return FhenixDemo.select(isAGreater, a, b);
    }

    /**
     * @notice Calculate encrypted minimum
     */
    function min(FhenixDemo.euint32 memory a, FhenixDemo.euint32 memory b) internal pure returns (FhenixDemo.euint32 memory result) {
        FhenixDemo.ebool memory isALess = FhenixDemo.lt(a, b);
        return FhenixDemo.select(isALess, a, b);
    }

    /**
     * @notice Calculate encrypted minimum
     */
    function min(FhenixDemo.euint64 memory a, FhenixDemo.euint64 memory b) internal pure returns (FhenixDemo.euint64 memory result) {
        FhenixDemo.ebool memory isALess = FhenixDemo.lt(a, b);
        return FhenixDemo.select(isALess, a, b);
    }

    // ==================== VALIDATION FUNCTIONS ====================

    /**
     * @notice Validate encrypted data format
     */
    function validateEncryptedData(FhenixDemo.euint256 memory data) internal pure returns (bool isValid) {
        return FhenixDemo.isInitialized(data);
    }

    /**
     * @notice Check if encrypted value is zero
     */
    function isZero(FhenixDemo.euint32 memory value) internal pure returns (FhenixDemo.ebool memory result) {
        FhenixDemo.euint32 memory zero = FhenixDemo.asEuint32(0);
        return FhenixDemo.eq(value, zero);
    }

    /**
     * @notice Check if encrypted value is zero
     */
    function isZero(FhenixDemo.euint64 memory value) internal pure returns (FhenixDemo.ebool memory result) {
        FhenixDemo.euint64 memory zero = FhenixDemo.asEuint64(0);
        return FhenixDemo.eq(value, zero);
    }

    /**
     * @notice Check if encrypted value is zero
     */
    function isZero(FhenixDemo.euint256 memory value) internal pure returns (FhenixDemo.ebool memory result) {
        FhenixDemo.euint256 memory zero = FhenixDemo.asEuint256(0);
        return FhenixDemo.eq(value, zero);
    }
}
