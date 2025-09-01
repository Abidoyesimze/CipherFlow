// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {Currency} from "v4-core/types/Currency.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {CipherFlowHook} from "../../src/CipherFlowHook.sol";
import {ICipherFlowHook} from "../../src/interfaces/ICipherFlow.sol";

library TestHelper {
    // Common test constants
    uint160 constant SQRT_RATIO_1_1 = 79228162514264337593543950336;
    int24 constant TICK_SPACING = 60;
    uint24 constant DEFAULT_FEE = 3000;
    
    function createDefaultPoolKey(
        address token0,
        address token1,
        CipherFlowHook hook
    ) internal pure returns (PoolKey memory) {
        return PoolKey({
            currency0: Currency.wrap(token0),
            currency1: Currency.wrap(token1),
            fee: DEFAULT_FEE,
            tickSpacing: TICK_SPACING,
            hooks: hook
        });
    }
    
    function createDefaultMEVConfig() internal view returns (ICipherFlowHook.MEVProtectionConfig memory) {
        return ICipherFlowHook.MEVProtectionConfig({
            volatilityThreshold: 500,
            baseFeeMultiplier: 150,
            maxFeeMultiplier: 300,
            mevDetectionWindow: 300,
            isEnabled: true,
            lastUpdate: block.timestamp
        });
    }
    
    function createDefaultLiquidityParams(
        uint256 amount
    ) internal pure returns (IPoolManager.ModifyLiquidityParams memory) {
        return IPoolManager.ModifyLiquidityParams({
            tickLower: -TICK_SPACING,
            tickUpper: TICK_SPACING,
            liquidityDelta: int256(amount)
        });
    }
    
    function createDefaultSwapParams(
        uint256 amount,
        bool zeroForOne
    ) internal pure returns (IPoolManager.SwapParams memory) {
        return IPoolManager.SwapParams({
            zeroForOne: zeroForOne,
            amountSpecified: int256(amount),
            sqrtPriceLimitX96: zeroForOne ? 
                4295128739 : // MIN_SQRT_RATIO + 1
                1461446703485210103287273052203988822378723970342 // MAX_SQRT_RATIO - 1
        });
    }
}