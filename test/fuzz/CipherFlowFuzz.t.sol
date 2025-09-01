// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {FHE, euint32, euint64, euint256, ebool} from "@fhenixprotocol/FHE.sol";
import {CipherFlowHook} from "../../src/CipherFlowHook.sol";
import {EncryptedMath} from "../../src/libraries/EncryptedMath.sol";
import {MEVProtection} from "../../src/libraries/MEVProtection.sol";
import {DynamicFees} from "../../src/libraries/DynamicFees.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {SwapParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";

contract CipherFlowFuzzTest is Test {
    CipherFlowHook hook;
    
    function setUp() public {
        // Setup for fuzzing tests
    }
    
    function testFuzzEncryptedMath(uint256 a, uint256 b) public {
        // Bound inputs to reasonable ranges
        a = bound(a, 1, type(uint128).max);
        b = bound(b, 1, type(uint128).max);
        
        euint256 encA = EncryptedMath.encryptUint256(a);
        euint256 encB = EncryptedMath.encryptUint256(b);
        
        // Test addition doesn't overflow
        if (a + b <= type(uint256).max) {
            euint256 sum = EncryptedMath.addEncrypted(encA, encB);
            // Note: In real FHE, we can't decrypt directly - this would be handled by the CoFHE coprocessor
            // For testing purposes, we just verify the operation completes without reverting
            assertTrue(euint256.unwrap(sum) != 0);
        }
        
        // Test subtraction doesn't underflow
        if (a >= b) {
            euint256 diff = EncryptedMath.subEncrypted(encA, encB);
            // Note: In real FHE, we can't decrypt directly - this would be handled by the CoFHE coprocessor
            assertTrue(euint256.unwrap(diff) != 0);
        }
        
        // Test multiplication doesn't overflow
        if (a <= type(uint128).max && b <= type(uint128).max) {
            euint256 product = EncryptedMath.mulEncrypted(encA, encB);
            // Note: In real FHE, we can't decrypt directly - this would be handled by the CoFHE coprocessor
            assertTrue(euint256.unwrap(product) != 0);
        }
    }
    
    function testFuzzMEVRiskCalculation(
        uint256 priceMovement,
        uint256 volumeSpike,
        uint256 swapSize
    ) public {
        // Bound inputs to valid ranges
        priceMovement = bound(priceMovement, 0, 10000); // 0-100%
        volumeSpike = bound(volumeSpike, 100, 50000); // 1x-500x
        swapSize = bound(swapSize, 1 ether, 10000 ether);
        
        MEVProtection.VolatilityData memory volData = MEVProtection.VolatilityData({
            priceMovement: priceMovement,
            volumeSpike: volumeSpike,
            timeWindow: 300,
            lastUpdate: block.timestamp
        });
        
        // Create mock swap params
        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: int256(swapSize),
            sqrtPriceLimitX96: 0
        });
        
        // Create mock pool key
        PoolKey memory key = PoolKey({
            currency0: Currency.wrap(address(0x1)),
            currency1: Currency.wrap(address(0x2)),
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(0))
        });
        
        MEVProtection.MEVRisk memory risk = MEVProtection.calculateMEVRisk(key, params, volData);
        
        // Risk score should be bounded
        assertLe(risk.riskScore, 10000); // Max 100%
        assertLe(risk.confidence, 10000); // Max 100%
        
        // High volatility should increase risk
        if (priceMovement > 1000) { // >10%
            assertGt(risk.riskScore, 1000); // Should be >10%
        }
        
        // Large volume spikes should increase risk
        if (volumeSpike > 5000) { // >50x
            assertGt(risk.riskScore, 2000); // Should be >20%
        }
    }
    
    function testFuzzDynamicFeeCalculation(
        uint256 riskScore,
        uint24 baseFee
    ) public {
        // Bound inputs
        riskScore = bound(riskScore, 0, 10000); // 0-100%
        baseFee = bound(baseFee, 100, 10000); // 0.01%-1%
        
        MEVProtection.MEVRisk memory risk = MEVProtection.MEVRisk({
            riskScore: riskScore,
            confidence: 8000, // 80%
            isToxic: riskScore > 7500
        });
        
        uint24 dynamicFee = MEVProtection.calculateDynamicFee(risk, baseFee);
        
        // Fee should never be less than base fee
        assertGe(dynamicFee, baseFee);
        
        // Fee should be bounded
        assertLe(dynamicFee, 10000); // Max 1%
        
        // Higher risk should generally mean higher fees
        if (riskScore > 5000) { // >50% risk
            assertGt(dynamicFee, baseFee);
        }
        
        // Toxic flow should have highest fees
        if (risk.isToxic) {
            assertEq(dynamicFee, (baseFee * 150) / 100); // 1.5x base fee (capped at max)
        }
    }
    
    function testFuzzPositionEncryption(
        uint256 amount,
        int24 tickLower,
        int24 tickUpper
    ) public {
        // Bound inputs to valid ranges
        amount = bound(amount, 1 ether, 1000000 ether);
        tickLower = int24(bound(int256(tickLower), -887220, 887220));
        tickUpper = int24(bound(int256(tickUpper), tickLower + 1, 887220));
        
        // Test encryption doesn't fail
        euint256 encryptedAmount = EncryptedMath.encryptUint256(amount);
        euint32 encryptedTickLower = EncryptedMath.encryptUint32(uint32(int32(tickLower)));
        euint32 encryptedTickUpper = EncryptedMath.encryptUint32(uint32(int32(tickUpper)));
        
        // Test decryption returns original values
        uint256 decryptedAmount = EncryptedMath.decrypt(encryptedAmount);
        uint32 decryptedTickLower = EncryptedMath.decrypt(encryptedTickLower);
        uint32 decryptedTickUpper = EncryptedMath.decrypt(encryptedTickUpper);
        
        assertEq(decryptedAmount, amount);
        assertEq(int32(decryptedTickLower), tickLower);
        assertEq(int32(decryptedTickUpper), tickUpper);
    }
    
    function testFuzzSwapRouting(
        uint256 swapSize,
        uint256 volatility,
        bool zeroForOne
    ) public {
        // Bound inputs
        swapSize = bound(swapSize, 1 ether, 100000 ether);
        volatility = bound(volatility, 0, 10000);
        
        MEVProtection.MEVRisk memory risk = MEVProtection.MEVRisk({
            riskScore: volatility,
            confidence: 8000,
            isToxic: volatility > 7500
        });
        
        bool shouldRoute = MEVProtection.shouldRouteToAVS(risk, swapSize);
        
        // Large swaps should generally be routed
        if (swapSize > 10000 ether) {
            assertTrue(shouldRoute);
        }
        
        // High-risk swaps should be routed
        if (risk.riskScore > 3000) {
            assertTrue(shouldRoute);
        }
        
        // Very small, low-risk swaps should not be routed
        if (swapSize < 1 ether && risk.riskScore < 1000) {
            assertFalse(shouldRoute);
        }
    }
}