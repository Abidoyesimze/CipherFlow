// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {SwapParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";

library MEVProtection {
    struct VolatilityData {
        uint256 priceMovement;
        uint256 volumeSpike;
        uint256 timeWindow;
        uint256 lastUpdate;
    }

    struct MEVRisk {
        uint256 riskScore;      // 0-10000 (0-100%)
        uint256 confidence;     // 0-10000 (0-100%)
        bool isToxic;          // High-confidence toxic flow
    }

    uint256 private constant VOLATILITY_THRESHOLD = 500; // 5%
    uint256 private constant VOLUME_SPIKE_THRESHOLD = 1000; // 10x
    uint256 private constant TIME_WINDOW = 60 seconds;
    uint256 private constant BASIS_POINTS = 10000;

    /**
     * @notice Calculate MEV risk score for a swap
     * @param key The pool key
     * @param params The swap parameters
     * @param volatilityData Current volatility data
     * @return risk The calculated MEV risk
     */
    function calculateMEVRisk(
        PoolKey memory key,
        SwapParams memory params,
        VolatilityData memory volatilityData
    ) internal pure returns (MEVRisk memory risk) {
        uint256 baseRisk = 0;

        // Factor 1: Price volatility
        if (volatilityData.priceMovement > VOLATILITY_THRESHOLD) {
            baseRisk += (volatilityData.priceMovement * 2000) / BASIS_POINTS;
        }

        // Factor 2: Volume spikes (potential sandwich attacks)
        if (volatilityData.volumeSpike > VOLUME_SPIKE_THRESHOLD) {
            baseRisk += 2000; // 20% risk increase
        }

        // Factor 3: Swap size relative to liquidity
        uint256 swapSizeRisk = _calculateSwapSizeRisk(params);
        baseRisk += swapSizeRisk;

        // Factor 4: Time-based patterns
        uint256 timeRisk = _calculateTimeRisk(volatilityData.lastUpdate);
        baseRisk += timeRisk;

        // Cap at 100%
        risk.riskScore = baseRisk > BASIS_POINTS ? BASIS_POINTS : baseRisk;
        
        // Calculate confidence based on data freshness
        risk.confidence = _calculateConfidence(volatilityData);
        
        // Mark as toxic if high risk and high confidence
        risk.isToxic = risk.riskScore > 7500 && risk.confidence > 8000;
    }

    /**
     * @notice Calculate dynamic fee multiplier based on MEV risk
     * @param risk The MEV risk assessment
     * @param baseFee The base fee for the pool
     * @return newFee The adjusted fee
     */
    function calculateDynamicFee(
        MEVRisk memory risk,
        uint24 baseFee
    ) internal pure returns (uint24 newFee) {
        if (risk.isToxic) {
            // Punitive fees for toxic flow
            newFee = uint24((uint256(baseFee) * 150) / 100); // 1.5x base fee
        } else if (risk.riskScore > 5000) {
            // Moderate increase for medium risk
            newFee = uint24((uint256(baseFee) * 125) / 100); // 1.25x base fee
        } else {
            // Keep base fee for low risk
            newFee = baseFee;
        }

        // Ensure fee doesn't exceed maximum (1%)
        if (newFee > 10000) newFee = 10000;
    }

    /**
     * @notice Check if a swap should be routed through AVS
     * @param risk The MEV risk assessment
     * @param swapValue The value of the swap in USD terms
     * @return shouldRoute Whether to route through AVS
     */
    function shouldRouteToAVS(
        MEVRisk memory risk,
        uint256 swapValue
    ) internal pure returns (bool shouldRoute) {
        // Route high-risk swaps and large swaps
        shouldRoute = risk.riskScore > 3000 || swapValue > 10000 ether; // $10k threshold
    }

    // Internal helper functions
    function _calculateSwapSizeRisk(
        SwapParams memory params
    ) private pure returns (uint256 risk) {
        // Larger swaps have higher MEV risk
        uint256 swapSize = params.amountSpecified < 0 
            ? uint256(-params.amountSpecified) 
            : uint256(params.amountSpecified);
        
        // Risk increases with swap size (simplified)
        if (swapSize > 100 ether) risk += 1000;
        if (swapSize > 1000 ether) risk += 2000;
    }

    function _calculateTimeRisk(uint256 lastUpdate) private view returns (uint256 risk) {
        uint256 timeSinceUpdate = block.timestamp - lastUpdate;
        
        // Higher risk if data is stale
        if (timeSinceUpdate > TIME_WINDOW * 2) {
            risk += 500; // 5% increase for stale data
        }
    }

    function _calculateConfidence(
        VolatilityData memory data
    ) private view returns (uint256 confidence) {
        uint256 timeSinceUpdate = block.timestamp - data.lastUpdate;
        
        // Confidence decreases with time
        if (timeSinceUpdate <= TIME_WINDOW) {
            confidence = BASIS_POINTS; // 100%
        } else if (timeSinceUpdate <= TIME_WINDOW * 2) {
            confidence = 7500; // 75%
        } else {
            confidence = 5000; // 50%
        }
    }
}