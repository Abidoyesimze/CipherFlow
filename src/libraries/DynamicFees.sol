// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {PoolKey} from "v4-core/types/PoolKey.sol";

library DynamicFees {
    struct FeeConfig {
        uint24 baseFee;           // Base fee in hundredths of bips
        uint24 minFee;            // Minimum fee
        uint24 maxFee;            // Maximum fee
        uint256 volatilityWindow; // Time window for volatility calculation
        uint256 lastUpdate;      // Last fee update timestamp
    }

    struct PriceData {
        uint256 price;
        uint256 timestamp;
        uint256 volume;
    }

    uint256 private constant BASIS_POINTS = 10000;
    uint256 private constant MAX_VOLATILITY = 2000; // 20%
    uint256 private constant MIN_UPDATE_INTERVAL = 60; // 1 minute

    error InvalidFeeConfig();
    error UpdateTooFrequent();

    /**
     * @notice Calculate optimal fee based on current market conditions
     * @param config Current fee configuration
     * @param currentPrice Current pool price
     * @param historicalPrices Array of recent price data
     * @param volume24h 24-hour trading volume
     * @return newFee Calculated optimal fee
     */
    function calculateOptimalFee(
        FeeConfig memory config,
        uint256 currentPrice,
        PriceData[] memory historicalPrices,
        uint256 volume24h
    ) internal view returns (uint24 newFee) {
        // Prevent too frequent updates
        if (block.timestamp - config.lastUpdate < MIN_UPDATE_INTERVAL) {
            return config.baseFee;
        }

        // Calculate volatility
        uint256 volatility = _calculateVolatility(currentPrice, historicalPrices);
        
        // Calculate volume factor
        uint256 volumeFactor = _calculateVolumeFactor(volume24h, historicalPrices);
        
        // Base fee adjustment
        uint256 feeMultiplier = BASIS_POINTS;
        
        // Increase fee with volatility
        feeMultiplier += (volatility * 50) / 100; // 0.5x volatility percentage
        
        // Adjust for volume (higher volume = lower fees for competitiveness)
        if (volumeFactor > BASIS_POINTS) {
            feeMultiplier = (feeMultiplier * 95) / 100; // 5% discount for high volume
        }
        
        // Apply multiplier
        newFee = uint24((uint256(config.baseFee) * feeMultiplier) / BASIS_POINTS);
        
        // Enforce bounds
        if (newFee < config.minFee) newFee = config.minFee;
        if (newFee > config.maxFee) newFee = config.maxFee;
    }

    /**
     * @notice Calculate fee adjustment for LP operations
     * @param isAdding Whether liquidity is being added
     * @param liquidityDelta Change in liquidity
     * @param currentLiquidity Current pool liquidity
     * @return feeAdjustment Fee adjustment in basis points
     */
    function calculateLiquidityIncentive(
        bool isAdding,
        uint256 liquidityDelta,
        uint256 currentLiquidity
    ) internal pure returns (int256 feeAdjustment) {
        uint256 liquidityRatio = (liquidityDelta * BASIS_POINTS) / currentLiquidity;
        
        if (isAdding) {
            // Reward large liquidity additions
            if (liquidityRatio > 1000) { // >10% increase
                feeAdjustment = -50; // 0.5% discount
            } else if (liquidityRatio > 500) { // >5% increase
                feeAdjustment = -25; // 0.25% discount
            }
        } else {
            // Penalize large liquidity removals
            if (liquidityRatio > 1000) { // >10% decrease
                feeAdjustment = 100; // 1% penalty
            } else if (liquidityRatio > 500) { // >5% decrease
                feeAdjustment = 50; // 0.5% penalty
            }
        }
    }

    /**
     * @notice Validate fee configuration
     * @param config Fee configuration to validate
     */
    function validateFeeConfig(FeeConfig memory config) internal pure {
        if (config.minFee > config.maxFee) revert InvalidFeeConfig();
        if (config.baseFee < config.minFee || config.baseFee > config.maxFee) {
            revert InvalidFeeConfig();
        }
        if (config.maxFee > BASIS_POINTS) revert InvalidFeeConfig(); // Max 100%
    }

    // Internal helper functions
    function _calculateVolatility(
        uint256 currentPrice,
        PriceData[] memory historicalPrices
    ) private pure returns (uint256 volatility) {
        if (historicalPrices.length < 2) return 0;
        
        uint256 priceSum = 0;
        uint256 count = 0;
        
        // Calculate average price
        for (uint256 i = 0; i < historicalPrices.length; i++) {
            priceSum += historicalPrices[i].price;
            count++;
        }
        
        if (count == 0) return 0;
        
        uint256 avgPrice = priceSum / count;
        
        // Calculate standard deviation
        uint256 varianceSum = 0;
        for (uint256 i = 0; i < historicalPrices.length; i++) {
            uint256 price = historicalPrices[i].price;
            uint256 diff = price > avgPrice ? price - avgPrice : avgPrice - price;
            varianceSum += (diff * diff);
        }
        
        uint256 variance = varianceSum / count;
        volatility = _sqrt(variance);
        
        // Convert to percentage
        volatility = (volatility * BASIS_POINTS) / avgPrice;
        
        // Cap volatility
        if (volatility > MAX_VOLATILITY) volatility = MAX_VOLATILITY;
    }

    function _calculateVolumeFactor(
        uint256 volume24h,
        PriceData[] memory historicalPrices
    ) private pure returns (uint256 factor) {
        if (historicalPrices.length == 0) return BASIS_POINTS;
        
        // Calculate average historical volume
        uint256 totalVolume = 0;
        for (uint256 i = 0; i < historicalPrices.length; i++) {
            totalVolume += historicalPrices[i].volume;
        }
        
        uint256 avgVolume = totalVolume / historicalPrices.length;
        
        if (avgVolume == 0) return BASIS_POINTS;
        
        // Factor based on current vs average volume
        factor = (volume24h * BASIS_POINTS) / avgVolume;
    }

    function _sqrt(uint256 x) private pure returns (uint256 result) {
        if (x == 0) return 0;
        
        // Babylonian method
        result = x;
        uint256 k = (x / 2) + 1;
        while (k < result) {
            result = k;
            k = (x / k + k) / 2;
        }
    }
}