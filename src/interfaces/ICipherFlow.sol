// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";
import {ModifyLiquidityParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
// import {euint32, euint64, euint256, ebool} from "@fhenixprotocol/FHE.sol"; // Using FhenixDemo instead
import {FhenixDemo} from "../libraries/FhenixDemo.sol";

/**
 * @title ICipherFlowHook
 * @notice Interface for the CipherFlow hook contract
 * @dev Defines the core functionality for MEV-resistant and confidential liquidity management
 */
interface ICipherFlowHook {
    // ==================== STRUCTS ====================
    
    /**
     * @notice Encrypted liquidity position data
     * @param encryptedAmount Encrypted liquidity amount
     * @param encryptedTickLower Encrypted lower tick
     * @param encryptedTickUpper Encrypted upper tick
     * @param encryptedStrategy Encrypted strategy parameters
     * @param timestamp Position creation timestamp
     * @param isActive Whether position is active
     * @param owner Position owner
     */
    struct EncryptedLPPosition {
        FhenixDemo.euint256 encryptedAmount;
        FhenixDemo.euint32 encryptedTickLower;
        FhenixDemo.euint32 encryptedTickUpper;
        FhenixDemo.euint256 encryptedStrategy;
        uint256 timestamp;
        bool isActive;
        address owner;
    }
    
    /**
     * @notice MEV protection configuration for a pool
     * @param volatilityThreshold Threshold for volatility-based fee adjustment
     * @param baseFeeMultiplier Base multiplier for fee calculation
     * @param maxFeeMultiplier Maximum allowed fee multiplier
     * @param mevDetectionWindow Time window for MEV detection
     * @param isEnabled Whether MEV protection is enabled
     * @param lastUpdate Last configuration update
     */
    struct MEVProtectionConfig {
        uint256 volatilityThreshold;
        uint256 baseFeeMultiplier;
        uint256 maxFeeMultiplier;
        uint256 mevDetectionWindow;
        bool isEnabled;
        uint256 lastUpdate;
    }
    
    /**
     * @notice Encrypted order data for AVS processing
     * @param encryptedAmount Encrypted swap amount
     * @param encryptedMinOut Encrypted minimum output
     * @param encryptedDeadline Encrypted deadline
     * @param swapper Order creator
     * @param poolId Target pool
     * @param isExactInput Whether it's exact input swap
     */
    struct EncryptedOrder {
        FhenixDemo.euint256 encryptedAmount;
        FhenixDemo.euint256 encryptedMinOut;
        FhenixDemo.euint64 encryptedDeadline;
        address swapper;
        PoolId poolId;
        bool isExactInput;
    }
    
    /**
     * @notice Dynamic fee parameters
     * @param currentFee Current dynamic fee
     * @param baseFee Base fee for the pool
     * @param lastUpdate Last fee update timestamp
     * @param volatilityScore Current volatility score
     * @param mevRiskScore Current MEV risk score
     */
    struct DynamicFeeData {
        uint24 currentFee;
        uint24 baseFee;
        uint256 lastUpdate;
        uint256 volatilityScore;
        uint256 mevRiskScore;
    }

    // ==================== EVENTS ====================
    
    /**
     * @notice Emitted when a swap is routed through EigenLayer AVS
     * @param poolId Pool identifier
     * @param batchId Batch identifier in AVS
     * @param swapper Address initiating the swap
     * @param mevRiskScore Calculated MEV risk score
     */
    event SwapRoutedToAVS(
        PoolId indexed poolId,
        bytes32 indexed batchId,
        address indexed swapper,
        uint256 mevRiskScore
    );
    
    /**
     * @notice Emitted when liquidity position is encrypted
     * @param poolId Pool identifier
     * @param provider Liquidity provider address
     * @param positionId Unique position identifier
     * @param timestamp Creation timestamp
     */
    event LiquidityEncrypted(
        PoolId indexed poolId,
        address indexed provider,
        bytes32 indexed positionId,
        uint256 timestamp
    );
    
    /**
     * @notice Emitted when dynamic fee is updated
     * @param poolId Pool identifier
     * @param oldFee Previous fee
     * @param newFee New dynamic fee
     * @param reason Reason for fee change
     * @param volatilityScore Current volatility score
     */
    event DynamicFeeUpdated(
        PoolId indexed poolId,
        uint24 oldFee,
        uint24 newFee,
        string reason,
        uint256 volatilityScore
    );
    
    /**
     * @notice Emitted when MEV protection config is updated
     * @param poolId Pool identifier
     * @param config New MEV protection configuration
     * @param updater Address that updated the config
     */
    event MEVProtectionConfigUpdated(
        PoolId indexed poolId,
        MEVProtectionConfig config,
        address indexed updater
    );
    
    /**
     * @notice Emitted when encrypted order batch is submitted to AVS
     * @param batchId Unique batch identifier
     * @param orderCount Number of orders in batch
     * @param submitter Address that submitted the batch
     */
    event OrderBatchSubmitted(
        bytes32 indexed batchId,
        uint256 orderCount,
        address indexed submitter
    );

    // ==================== ERRORS ====================
    
    error InvalidPoolKey();
    error UnauthorizedAccess();
    error MEVProtectionNotEnabled();
    error InvalidFeeConfiguration();
    error EncryptionFailed();
    error AVSSubmissionFailed();
    error InvalidVolatilityData();
    error ExcessiveSwapSize();
    error ToxicOrderFlow();
    error InsufficientLiquidity();

    // ==================== EXTERNAL FUNCTIONS ====================
    
    /**
     * @notice Encrypt liquidity position data
     * @param key Pool key
     * @param params Liquidity modification parameters
     * @param strategyData Additional strategy parameters
     * @return positionId Unique identifier for the encrypted position
     */
    function encryptLPPosition(
        PoolKey calldata key,
        ModifyLiquidityParams calldata params,
        bytes calldata strategyData
    ) external returns (bytes32 positionId);
    
    /**
     * @notice Calculate dynamic fee based on current market conditions
     * @param key Pool key
     * @return fee Calculated dynamic fee
     */
    function calculateDynamicFee(PoolKey calldata key) external view returns (uint24 fee);
    
    /**
     * @notice Get MEV protection configuration for a pool
     * @param poolId Pool identifier
     * @return config Current MEV protection configuration
     */
    function getMEVProtectionConfig(PoolId poolId) external view returns (MEVProtectionConfig memory config);
    
    /**
     * @notice Get encrypted liquidity position data
     * @param positionId Position identifier
     * @param userPublicKey User's public key for decryption
     * @return sealedData Sealed position data that only the user can decrypt
     */
    function getEncryptedPosition(
        bytes32 positionId,
        bytes32 userPublicKey
    ) external view returns (bytes memory sealedData);
    
    /**
     * @notice Submit encrypted order to AVS for processing
     * @param order Encrypted order data
     * @return batchId Batch identifier in AVS
     */
    function submitEncryptedOrder(EncryptedOrder calldata order) external returns (bytes32 batchId);
    
    /**
     * @notice Update MEV protection configuration (only authorized)
     * @param poolId Pool identifier
     * @param config New configuration
     */
    function updateMEVProtectionConfig(
        PoolId poolId,
        MEVProtectionConfig calldata config
    ) external;
    
    /**
     * @notice Get current dynamic fee data for a pool
     * @param poolId Pool identifier
     * @return feeData Current dynamic fee information
     */
    function getDynamicFeeData(PoolId poolId) external view returns (DynamicFeeData memory feeData);
}