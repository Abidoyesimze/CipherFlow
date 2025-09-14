// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {SwapParams, ModifyLiquidityParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {console} from "forge-std/console.sol";

/**
 * @title SimpleTestRouter
 * @notice Simplified router for testing Uniswap v4 operations in fork tests
 * @dev This router handles basic operations for testing purposes
 */
contract SimpleTestRouter {
    IPoolManager public immutable manager;

    error SwapFailed();

    constructor(IPoolManager _manager) {
        manager = _manager;
    }

    /**
     * @notice Execute exact input single swap
     * @param params Swap parameters
     * @param poolKey Pool key for the swap
     * @param recipient Recipient of output tokens
     */
    function exactInputSingle(
        SwapParams memory params,
        PoolKey memory poolKey,
        bytes calldata recipient
    ) external {
        // For fork tests, we'll use a simplified approach
        // In a real implementation, you'd need to handle token transfers properly
        
        // Execute swap through the PoolManager
        BalanceDelta delta = manager.swap(poolKey, params, abi.encodePacked(recipient));
        
        // Log the swap result
        console.log("Swap executed - Delta amount0:", delta.amount0());
        console.log("Swap executed - Delta amount1:", delta.amount1());
    }

    /**
     * @notice Add liquidity to a pool
     * @param poolKey Pool key
     * @param params Modify liquidity parameters
     * @param salt Salt for the position
     */
    function addLiquidity(
        PoolKey memory poolKey,
        ModifyLiquidityParams memory params,
        bytes32 salt
    ) external {
        // Execute modify liquidity
        (BalanceDelta delta, ) = manager.modifyLiquidity(poolKey, params, abi.encodePacked(msg.sender));
        
        // Log the liquidity addition result
        console.log("Liquidity added - Delta amount0:", delta.amount0());
        console.log("Liquidity added - Delta amount1:", delta.amount1());
    }

    /**
     * @notice Remove liquidity from a pool
     * @param poolKey Pool key
     * @param params Modify liquidity parameters
     * @param salt Salt for the position
     */
    function removeLiquidity(
        PoolKey memory poolKey,
        ModifyLiquidityParams memory params,
        bytes32 salt
    ) external {
        // Execute modify liquidity (negative delta for removal)
        (BalanceDelta delta, ) = manager.modifyLiquidity(poolKey, params, abi.encodePacked(msg.sender));
        
        // Log the liquidity removal result
        console.log("Liquidity removed - Delta amount0:", delta.amount0());
        console.log("Liquidity removed - Delta amount1:", delta.amount1());
    }
}
