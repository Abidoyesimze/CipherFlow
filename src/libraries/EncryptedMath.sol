// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {FHE, euint32, euint64, euint256, ebool} from "@fhenixprotocol/FHE.sol";

/**
 * @title EncryptedMath
 * @notice Production-ready library for encrypted mathematical operations
 * @dev Uses real FHE operations for secure computation
 */
library EncryptedMath {

    error InvalidEncryptedData();
    error ComputationFailed();
    error DivisionByZero();

    // ==================== ARITHMETIC OPERATIONS ====================
    
    /**
     * @notice Add two encrypted uint32 values
     */
    function addEncrypted(euint32 a, euint32 b) internal pure returns (euint32 result) {
        return FHE.add(a, b);
    }

    /**
     * @notice Add two encrypted uint64 values
     */
    function addEncrypted(euint64 a, euint64 b) internal pure returns (euint64 result) {
        return FHE.add(a, b);
    }

    /**
     * @notice Add two encrypted uint256 values
     */
    function addEncrypted(euint256 a, euint256 b) internal pure returns (euint256 result) {
        return FHE.add(a, b);
    }

    /**
     * @notice Subtract two encrypted uint32 values
     */
    function subEncrypted(euint32 a, euint32 b) internal pure returns (euint32 result) {
        return FHE.sub(a, b);
    }

    /**
     * @notice Subtract two encrypted uint64 values
     */
    function subEncrypted(euint64 a, euint64 b) internal pure returns (euint64 result) {
        return FHE.sub(a, b);
    }

    /**
     * @notice Subtract two encrypted uint256 values
     */
    function subEncrypted(euint256 a, euint256 b) internal pure returns (euint256 result) {
        return FHE.sub(a, b);
    }

    /**
     * @notice Multiply two encrypted uint32 values
     */
    function mulEncrypted(euint32 a, euint32 b) internal pure returns (euint32 result) {
        return FHE.mul(a, b);
    }

    /**
     * @notice Multiply two encrypted uint64 values
     */
    function mulEncrypted(euint64 a, euint64 b) internal pure returns (euint64 result) {
        return FHE.mul(a, b);
    }

    /**
     * @notice Multiply two encrypted uint256 values
     */
    function mulEncrypted(euint256 a, euint256 b) internal pure returns (euint256 result) {
        return FHE.mul(a, b);
    }

    /**
     * @notice Divide two encrypted uint32 values
     */
    function divEncrypted(euint32 a, euint32 b) internal pure returns (euint32 result) {
        return FHE.div(a, b);
    }

    /**
     * @notice Divide two encrypted uint64 values
     */
    function divEncrypted(euint64 a, euint64 b) internal pure returns (euint64 result) {
        return FHE.div(a, b);
    }

    // ==================== CONVERSION FUNCTIONS ====================

    /**
     * @notice Convert plaintext uint32 to encrypted euint32
     */
    function encryptUint32(uint32 value) internal pure returns (euint32 encrypted) {
        return FHE.asEuint32(value);
    }

    /**
     * @notice Convert plaintext uint64 to encrypted euint64
     */
    function encryptUint64(uint64 value) internal pure returns (euint64 encrypted) {
        return FHE.asEuint64(value);
    }

    /**
     * @notice Convert plaintext uint256 to encrypted euint256
     */
    function encryptUint256(uint256 value) internal pure returns (euint256 encrypted) {
        return FHE.asEuint256(value);
    }



    // ==================== COMPARISON OPERATIONS ====================

    /**
     * @notice Greater than comparison for euint32
     */
    function gt(euint32 a, euint32 b) internal pure returns (ebool result) {
        return FHE.gt(a, b);
    }

    /**
     * @notice Greater than comparison for euint64
     */
    function gt(euint64 a, euint64 b) internal pure returns (ebool result) {
        return FHE.gt(a, b);
    }

    /**
     * @notice Greater than comparison for euint256
     */
    function gt(euint256 a, euint256 b) internal pure returns (ebool result) {
        return FHE.gt(a, b);
    }

    /**
     * @notice Less than comparison for euint32
     */
    function lt(euint32 a, euint32 b) internal pure returns (ebool result) {
        return FHE.lt(a, b);
    }

    /**
     * @notice Less than comparison for euint64
     */
    function lt(euint64 a, euint64 b) internal pure returns (ebool result) {
        return FHE.lt(a, b);
    }

    /**
     * @notice Equality comparison for euint32
     */
    function eq(euint32 a, euint32 b) internal pure returns (ebool result) {
        return FHE.eq(a, b);
    }

    /**
     * @notice Equality comparison for euint64
     */
    function eq(euint64 a, euint64 b) internal pure returns (ebool result) {
        return FHE.eq(a, b);
    }

    // ==================== CONDITIONAL SELECTION ====================

    /**
     * @notice Conditional selection between encrypted uint32 values
     */
    function select(ebool condition, euint32 trueValue, euint32 falseValue) 
        internal pure returns (euint32 result) {
        return FHE.select(condition, trueValue, falseValue);
    }

    /**
     * @notice Conditional selection between encrypted uint64 values
     */
    function select(ebool condition, euint64 trueValue, euint64 falseValue) 
        internal pure returns (euint64 result) {
        return FHE.select(condition, trueValue, falseValue);
    }

    /**
     * @notice Conditional selection between encrypted uint256 values
     */
    function select(ebool condition, euint256 trueValue, euint256 falseValue) 
        internal pure returns (euint256 result) {
        return FHE.select(condition, trueValue, falseValue);
    }

    // ==================== DECRYPTION FUNCTIONS ====================
    // Note: CoFHE uses asynchronous decryption via coprocessor
    // Direct decryption is not available in smart contracts
    // Use CoFHE's unsealing mechanism instead

    // ==================== SEALING FUNCTIONS ====================

    /**
     * @notice Seal euint32 for specific user
     * @dev Sealing operations are handled by the CoFHE coprocessor
     */
    function seal(euint32 encrypted, bytes32 publicKey) internal pure returns (bytes memory sealedData) {
        // TODO: Implement with CoFHE coprocessor integration
        revert("Sealing not yet implemented - requires CoFHE coprocessor");
    }

    /**
     * @notice Seal euint64 for specific user
     * @dev Sealing operations are handled by the CoFHE coprocessor
     */
    function seal(euint64 encrypted, bytes32 publicKey) internal pure returns (bytes memory sealedData) {
        // TODO: Implement with CoFHE coprocessor integration
        revert("Sealing not yet implemented - requires CoFHE coprocessor");
    }

    /**
     * @notice Seal euint256 for specific user
     * @dev Sealing operations are handled by the CoFHE coprocessor
     */
    function seal(euint256 encrypted, bytes32 publicKey) internal pure returns (bytes memory sealedData) {
        // TODO: Implement with CoFHE coprocessor integration
        revert("Sealing not yet implemented - requires CoFHE coprocessor");
    }

    // ==================== ADVANCED OPERATIONS ====================

    /**
     * @notice Calculate encrypted percentage
     */
    function calculatePercentage(euint256 value, uint256 percentage) 
        internal pure returns (euint256 result) {
        euint256 encryptedPercentage = FHE.asEuint256(percentage);
        euint256 basisPoints = FHE.asEuint256(10000);
        return FHE.div(FHE.mul(value, encryptedPercentage), basisPoints);
    }

    /**
     * @notice Calculate encrypted maximum
     */
    function max(euint32 a, euint32 b) internal pure returns (euint32 result) {
        ebool isAGreater = FHE.gt(a, b);
        return FHE.select(isAGreater, a, b);
    }

    /**
     * @notice Calculate encrypted maximum
     */
    function max(euint64 a, euint64 b) internal pure returns (euint64 result) {
        ebool isAGreater = FHE.gt(a, b);
        return FHE.select(isAGreater, a, b);
    }

    /**
     * @notice Calculate encrypted minimum
     */
    function min(euint32 a, euint32 b) internal pure returns (euint32 result) {
        ebool isALess = FHE.lt(a, b);
        return FHE.select(isALess, a, b);
    }

    /**
     * @notice Calculate encrypted minimum
     */
    function min(euint64 a, euint64 b) internal pure returns (euint64 result) {
        ebool isALess = FHE.lt(a, b);
        return FHE.select(isALess, a, b);
    }

    // ==================== VALIDATION FUNCTIONS ====================

    /**
     * @notice Validate encrypted data format
     */
    function validateEncryptedData(euint256 data) internal pure returns (bool isValid) {
        // Validation logic for encrypted data
        uint256 unwrapped = euint256.unwrap(data);
        return unwrapped != 0; // Basic validation
    }

    /**
     * @notice Check if encrypted value is zero
     */
    function isZero(euint32 value) internal pure returns (ebool result) {
        euint32 zero = FHE.asEuint32(0);
        return FHE.eq(value, zero);
    }

    /**
     * @notice Check if encrypted value is zero
     */
    function isZero(euint64 value) internal pure returns (ebool result) {
        euint64 zero = FHE.asEuint64(0);
        return FHE.eq(value, zero);
    }

    /**
     * @notice Check if encrypted value is zero
     */
    function isZero(euint256 value) internal pure returns (ebool result) {
        euint256 zero = FHE.asEuint256(0);
        return FHE.eq(value, zero);
    }
}