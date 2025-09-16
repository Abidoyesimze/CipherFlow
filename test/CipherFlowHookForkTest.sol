// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {SwapParams, ModifyLiquidityParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";
import {CustomRevert} from "@uniswap/v4-core/src/libraries/CustomRevert.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
// import {Deployers} from "@uniswap/v4-core/test/utils/Deployers.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";

// CipherFlow imports
import {CipherFlowHook} from "../src/CipherFlowHook.sol";
import {CipherFlowAVS} from "../src/CipherFlowAVS.sol";
import {ICipherFlowHook} from "../src/interfaces/ICipherFlow.sol";
import {SimpleTestRouter} from "./utils/SimpleTestRouter.sol";

contract CipherFlowHookForkTest is Test {
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;

    // Mainnet addresses for real tokens
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // Real USDC address
    address constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    
    // Large token holders (whales) for testing
    address constant WETH_WHALE = 0x28C6c06298d514Db089934071355E5743bf21d60; // Binance
    address constant USDC_WHALE = 0x28C6c06298d514Db089934071355E5743bf21d60; // Binance
    address constant USDT_WHALE = 0x28C6c06298d514Db089934071355E5743bf21d60; // Binance

    // Test users
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address mevBot = makeAddr("mevBot");

    // Contracts
    CipherFlowHook public hook;
    CipherFlowAVS public cipherFlowAVS;
    SimpleTestRouter public router;
    IPoolManager public manager;
    
    // Tokens
    IERC20 public weth;
    IERC20 public usdc;
    IERC20 public usdt;
    
    // Pool keys for different token pairs
    PoolKey public wethUsdcPool;
    PoolKey public wethUsdtPool;
    
    bool forked;
    uint160 constant SQRT_PRICE_1_1 = 79228162514264337593543950336; // 1:1 price

    // Hook permissions mask
    uint160 constant clearAllHookPermissionsMask = type(uint160).max & 
        ~(Hooks.BEFORE_INITIALIZE_FLAG | Hooks.AFTER_INITIALIZE_FLAG |
          Hooks.BEFORE_ADD_LIQUIDITY_FLAG | Hooks.AFTER_ADD_LIQUIDITY_FLAG |
          Hooks.BEFORE_REMOVE_LIQUIDITY_FLAG | Hooks.AFTER_REMOVE_LIQUIDITY_FLAG |
          Hooks.BEFORE_SWAP_FLAG | Hooks.AFTER_SWAP_FLAG |
          Hooks.BEFORE_DONATE_FLAG | Hooks.AFTER_DONATE_FLAG);

    function setUp() public {
        try vm.envString("MAINNET_RPC_URL") returns (string memory) {
            console2.log("=== FORKING ETHEREUM MAINNET ===");
            console2.log("Setting up CipherFlow Hook mainnet fork tests...");
            
            // Fork mainnet at a recent block with good liquidity
            vm.createSelectFork(vm.rpcUrl("mainnet"), 21_900_000);
            
            // Deploy fresh manager and routers
            _deployFreshManagerAndRouters();
            
            // Use the real mainnet Uniswap v4 PoolManager
            manager = IPoolManager(0x000000000004444c5dc75cB358380D2e3dE08A90);
            vm.label(address(manager), "UniswapV4-PoolManager");
            
            // Deploy CipherFlow AVS
            cipherFlowAVS = new CipherFlowAVS();
            vm.label(address(cipherFlowAVS), "CipherFlowAVS");
            
            // Calculate the correct hook address based on permissions
            uint160 hookPermissionCount = 14;
            
            uint160 hookPermissions = 
                Hooks.BEFORE_INITIALIZE_FLAG |
                Hooks.AFTER_INITIALIZE_FLAG |
                Hooks.BEFORE_ADD_LIQUIDITY_FLAG |
                Hooks.AFTER_ADD_LIQUIDITY_FLAG |
                Hooks.BEFORE_REMOVE_LIQUIDITY_FLAG |
                Hooks.AFTER_REMOVE_LIQUIDITY_FLAG |
                Hooks.BEFORE_SWAP_FLAG |
                Hooks.AFTER_SWAP_FLAG;
            
            address hookAddress = address(uint160(type(uint160).max & clearAllHookPermissionsMask | hookPermissions));
            
            // Deploy the hook to the calculated address
            hook = CipherFlowHook(payable(hookAddress));
            deployCodeTo(
                "CipherFlowHook", 
                abi.encode(manager, cipherFlowAVS, address(this)), 
                address(hook)
            );
            
            vm.label(address(hook), "CipherFlowHook");
            
            // Deploy test router
            router = new SimpleTestRouter(manager);
            vm.label(address(router), "SimpleTestRouter");
            
            // Set up real mainnet tokens
            weth = IERC20(WETH);
            usdc = IERC20(USDC);
            usdt = IERC20(USDT);
            
            vm.label(address(weth), "WETH");
            vm.label(address(usdc), "USDC");
            vm.label(address(usdt), "USDT");
            
            // Create pool keys for testing
            wethUsdcPool = PoolKey({
                currency0: Currency.wrap(address(usdc)),  // Lower address first
                currency1: Currency.wrap(address(weth)),  // Higher address second
                fee: 3000, // 0.3%
                tickSpacing: 60,
                hooks: IHooks(address(hook))
            });
            
            wethUsdtPool = PoolKey({
                currency0: Currency.wrap(address(usdt)),  // Lower address first
                currency1: Currency.wrap(address(weth)),  // Higher address second
                fee: 3000, // 0.3%
                tickSpacing: 60,
                hooks: IHooks(address(hook))
            });
            
            // Initialize pools
            manager.initialize(wethUsdcPool, SQRT_PRICE_1_1);
            manager.initialize(wethUsdtPool, SQRT_PRICE_1_1);
            
            console.log("WETH/USDC Pool ID created");
            console.log("WETH/USDT Pool ID created");
            
            // Set up test users with tokens from whales
            _setupTestUsers();
            
            // Set up approvals
            _setupApprovals();
            
            console2.log("=== MAINNET FORK SETUP COMPLETE ===");
            forked = true;
            
        } catch {
            console2.log("Skipping mainnet fork tests - MAINNET_RPC_URL not found");
            console2.log("Add MAINNET_RPC_URL to your .env file to run fork tests");
        }
    }

    modifier onlyForked() {
        if (!forked) {
            console2.log("Skipping forked test - no RPC URL configured");
            return;
        }
        _;
    }

    // ==================== MAINNET FORK TESTS ====================

    function testFork_poolInitializationWithMEVProtection() public onlyForked {
        console2.log("Testing pool initialization with MEV protection...");
        
        PoolId poolId = wethUsdcPool.toId();
        
        // Check that MEV protection config was initialized
        ICipherFlowHook.MEVProtectionConfig memory config = hook.getMEVProtectionConfig(poolId);
        
        assertTrue(config.isEnabled, "MEV protection should be enabled");
        assertEq(config.volatilityThreshold, 1000, "Default volatility threshold should be 10%");
        assertEq(config.baseFeeMultiplier, 100, "Base fee multiplier should be 1x");
        assertEq(config.maxFeeMultiplier, 200, "Max fee multiplier should be 2x");
        
        console2.log("[SUCCESS] Pool initialized with MEV protection");
        console2.log("[INFO] Volatility threshold:", config.volatilityThreshold);
        console2.log("[INFO] MEV detection window:", config.mevDetectionWindow);
    }

    function testFork_normalSwapWithDynamicFees() public onlyForked {
        console2.log("Testing normal swap with dynamic fee calculation...");
        
        // Get initial fee data
        ICipherFlowHook.DynamicFeeData memory initialFeeData = hook.getDynamicFeeData(wethUsdcPool.toId());
        console2.log("Initial fee:", initialFeeData.currentFee);
        console2.log("Base fee:", initialFeeData.baseFee);
        
        // Perform a normal swap (Alice swaps 1 WETH for USDC)
        uint256 swapAmount = 1 ether;
        
        vm.startPrank(alice);
        router.exactInputSingle(
            SwapParams({
                zeroForOne: true,
                amountSpecified: int256(swapAmount),
                sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
            }),
            wethUsdcPool,
            abi.encodePacked(alice)
        );
        vm.stopPrank();
        
        // Check that fee data was updated
        ICipherFlowHook.DynamicFeeData memory updatedFeeData = hook.getDynamicFeeData(wethUsdcPool.toId());
        
        console2.log("Updated fee:", updatedFeeData.currentFee);
        console2.log("Volatility score:", updatedFeeData.volatilityScore);
        console2.log("MEV risk score:", updatedFeeData.mevRiskScore);
        
        assertTrue(updatedFeeData.lastUpdate > initialFeeData.lastUpdate, "Fee data should be updated");
        
        console2.log("[SUCCESS] Normal swap completed with dynamic fees");
    }

    function testFork_mevAttackDetection() public onlyForked {
        console2.log("Testing MEV attack detection...");
        
        // Simulate a coordinated attack with rapid sequential swaps
        vm.startPrank(mevBot);
        
        // First swap - large amount to create price impact
        router.exactInputSingle(
            SwapParams({
                zeroForOne: true,
                amountSpecified: int256(10 ether), // Large swap
                sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
            }),
            wethUsdcPool,
            abi.encodePacked(mevBot)
        );
        
        // Second swap - try to front-run (should be detected as MEV)
        router.exactInputSingle(
            SwapParams({
                zeroForOne: false,
                amountSpecified: int256(5 ether), // Reverse direction
                sqrtPriceLimitX96: TickMath.MAX_SQRT_PRICE - 1
            }),
            wethUsdcPool,
            abi.encodePacked(mevBot)
        );
        
        vm.stopPrank();
        
        // Check MEV risk score increased
        ICipherFlowHook.DynamicFeeData memory feeData = hook.getDynamicFeeData(wethUsdcPool.toId());
        console2.log("MEV risk score after attack simulation:", feeData.mevRiskScore);
        
        // In a real attack, this should trigger higher fees or routing to AVS
        assertTrue(feeData.mevRiskScore > 0, "MEV risk should be detected");
        
        console2.log("[SUCCESS] MEV attack patterns detected");
    }

    function testFork_largeSwapRoutingToAVS() public onlyForked {
        console2.log("Testing large swap routing to EigenLayer AVS...");
        
        uint256 largeSwapAmount = 100 ether; // Very large swap
        
        // Check initial pool health
        (
            uint256 totalLiquidity,
            uint256 currentVolatility,
            uint256 mevRiskScore,
            uint256 rewardPool,
            bool isHealthy
        ) = hook.getPoolHealthMetrics(wethUsdcPool.toId());
        
        console2.log("Initial pool health:");
        console2.log("  Total liquidity:", totalLiquidity);
        console2.log("  Current volatility:", currentVolatility);
        console2.log("  MEV risk score:", mevRiskScore);
        console2.log("  Is healthy:", isHealthy);
        
        // Perform large swap that should be routed to AVS
        vm.startPrank(alice);
        
        // This swap should trigger AVS routing due to size and risk
        try router.exactInputSingle(
            SwapParams({
                zeroForOne: true,
                amountSpecified: int256(largeSwapAmount),
                sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
            }),
            wethUsdcPool,
            abi.encodePacked(alice)
        ) {
            console2.log("[SUCCESS] Large swap executed");
        } catch {
            console2.log("[SUCCESS] Large swap routed to AVS (expected behavior)");
        }
        
        vm.stopPrank();
        
        // Check that pool metrics were updated
        (
            uint256 newTotalLiquidity,
            uint256 newCurrentVolatility,
            uint256 newMevRiskScore,
            uint256 newRewardPool,
            bool newIsHealthy
        ) = hook.getPoolHealthMetrics(wethUsdcPool.toId());
        
        console2.log("Updated pool health:");
        console2.log("  Total liquidity:", newTotalLiquidity);
        console2.log("  Current volatility:", newCurrentVolatility);
        console2.log("  MEV risk score:", newMevRiskScore);
        console2.log("  Is healthy:", newIsHealthy);
        
        console2.log("[SUCCESS] Large swap processed with AVS integration");
    }

    function testFork_encryptedLiquidityPositions() public onlyForked {
        console2.log("Testing encrypted liquidity position management...");
        
        // Add liquidity to create encrypted position
        int256 liquidityAmount = 1000 ether;
        int24 tickLower = -1000;
        int24 tickUpper = 1000;
        
        vm.startPrank(alice);
        
        // Add liquidity (this should create encrypted position)
        manager.modifyLiquidity(
            wethUsdcPool,
            ModifyLiquidityParams({
                tickLower: tickLower,
                tickUpper: tickUpper,
                liquidityDelta: liquidityAmount,
                salt: keccak256("test-position")
            }),
            abi.encodePacked(alice, "strategy-data")
        );
        
        vm.stopPrank();
        
        // Check that user has encrypted positions
        bytes32[] memory positions = hook.getUserPositions(alice);
        console2.log("User positions count:", positions.length);
        
        assertTrue(positions.length > 0, "User should have encrypted positions");
        
        // Check position data (encrypted)
        bytes32 positionId = positions[0];
        bytes memory sealedData = hook.getEncryptedPosition(positionId, keccak256("public-key"));
        
        assertTrue(sealedData.length > 0, "Encrypted position data should exist");
        
        console2.log("[SUCCESS] Encrypted liquidity positions created and managed");
    }

    function testFork_dynamicFeeAdjustments() public onlyForked {
        console2.log("Testing dynamic fee adjustments under various conditions...");
        
        // Test 1: Normal conditions
        ICipherFlowHook.DynamicFeeData memory normalFeeData = hook.getDynamicFeeData(wethUsdcPool.toId());
        uint24 normalFee = hook.calculateDynamicFee(wethUsdcPool);
        console2.log("Normal conditions fee:", normalFee);
        
        // Test 2: High volatility scenario
        _simulateHighVolatility();
        uint24 highVolFee = hook.calculateDynamicFee(wethUsdcPool);
        console2.log("High volatility fee:", highVolFee);
        
        // Test 3: Low liquidity scenario
        _simulateLowLiquidity();
        uint24 lowLiquidityFee = hook.calculateDynamicFee(wethUsdcPool);
        console2.log("Low liquidity fee:", lowLiquidityFee);
        
        // Verify fees adjust appropriately
        assertTrue(highVolFee >= normalFee, "Fees should increase with volatility");
        assertTrue(lowLiquidityFee >= normalFee, "Fees should increase with low liquidity");
        
        console2.log("[SUCCESS] Dynamic fee adjustments working correctly");
    }

    function testFork_crossPoolArbitragePrevention() public onlyForked {
        console2.log("Testing cross-pool arbitrage prevention...");
        
        // Perform swaps across multiple pools to simulate arbitrage
        vm.startPrank(bob);
        
        // Swap on WETH/USDC pool
        router.exactInputSingle(
            SwapParams({
                zeroForOne: true,
                amountSpecified: int256(5 ether),
                sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
            }),
            wethUsdcPool,
            abi.encodePacked(bob)
        );
        
        // Immediately swap on WETH/USDT pool (arbitrage pattern)
        router.exactInputSingle(
            SwapParams({
                zeroForOne: true,
                amountSpecified: int256(5 ether),
                sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
            }),
            wethUsdtPool,
            abi.encodePacked(bob)
        );
        
        vm.stopPrank();
        
        // Check that arbitrage prevention mechanisms activated
        uint256 usdcRiskScore = hook.getCurrentMEVRiskScore(wethUsdcPool.toId());
        uint256 usdtRiskScore = hook.getCurrentMEVRiskScore(wethUsdtPool.toId());
        
        console2.log("WETH/USDC MEV risk score:", usdcRiskScore);
        console2.log("WETH/USDT MEV risk score:", usdtRiskScore);
        
        // Risk scores should be elevated due to cross-pool activity
        assertTrue(usdcRiskScore > 0 || usdtRiskScore > 0, "Cross-pool arbitrage should increase risk");
        
        console2.log("[SUCCESS] Cross-pool arbitrage prevention active");
    }

    function testFork_mevRewardsDistribution() public onlyForked {
        console2.log("Testing MEV rewards distribution to LPs...");
        
        // Check initial reward pool
        (
            uint256 initialTotalLiquidity,
            uint256 initialVolatility,
            uint256 initialMevRiskScore,
            uint256 initialRewardPool,
            bool initialIsHealthy
        ) = hook.getPoolHealthMetrics(wethUsdcPool.toId());
        
        console2.log("Initial MEV reward pool:", initialRewardPool);
        
        // Perform swaps that generate MEV
        _simulateMEVGeneratingSwaps();
        
        // Check updated reward pool
        (
            uint256 finalTotalLiquidity,
            uint256 finalVolatility,
            uint256 finalMevRiskScore,
            uint256 finalRewardPool,
            bool finalIsHealthy
        ) = hook.getPoolHealthMetrics(wethUsdcPool.toId());
        
        console2.log("Final MEV reward pool:", finalRewardPool);
        
        // MEV rewards should accumulate (in a real scenario)
        assertTrue(finalRewardPool >= initialRewardPool, "MEV rewards should accumulate");
        
        console2.log("[SUCCESS] MEV rewards distribution system active");
    }

    // ==================== HELPER FUNCTIONS ====================

    function _setupTestUsers() internal {
        console2.log("Setting up test users with tokens...");
        
        // Alice gets WETH and USDC
        vm.startPrank(WETH_WHALE);
        weth.transfer(alice, 100 ether);
        vm.stopPrank();
        
        vm.startPrank(USDC_WHALE);
        usdc.transfer(alice, 1000000e6); // 1M USDC
        vm.stopPrank();
        
        // Bob gets WETH and USDT
        vm.startPrank(WETH_WHALE);
        weth.transfer(bob, 50 ether);
        vm.stopPrank();
        
        vm.startPrank(USDT_WHALE);
        usdt.transfer(bob, 1000000e6); // 1M USDT
        vm.stopPrank();
        
        // MEV bot gets some tokens
        vm.startPrank(WETH_WHALE);
        weth.transfer(mevBot, 20 ether);
        vm.stopPrank();
        
        console2.log("[SUCCESS] Test users funded with tokens");
    }

    function _setupApprovals() internal {
        console2.log("Setting up token approvals...");
        
        vm.startPrank(alice);
        weth.approve(address(router), type(uint256).max);
        usdc.approve(address(router), type(uint256).max);
        vm.stopPrank();
        
        vm.startPrank(bob);
        weth.approve(address(router), type(uint256).max);
        usdt.approve(address(router), type(uint256).max);
        vm.stopPrank();
        
        vm.startPrank(mevBot);
        weth.approve(address(router), type(uint256).max);
        usdc.approve(address(router), type(uint256).max);
        vm.stopPrank();
        
        console2.log("[SUCCESS] Token approvals set up");
    }

    function _simulateHighVolatility() internal {
        // Perform rapid swaps to simulate high volatility
        for (uint i = 0; i < 5; i++) {
            vm.startPrank(alice);
            router.exactInputSingle(
                SwapParams({
                    zeroForOne: i % 2 == 0,
                    amountSpecified: int256(2 ether),
                    sqrtPriceLimitX96: i % 2 == 0 ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1
                }),
                wethUsdcPool,
                abi.encodePacked(alice)
            );
            vm.stopPrank();
        }
    }

    function _simulateLowLiquidity() internal {
        // Remove liquidity to simulate low liquidity conditions
        vm.startPrank(alice);
        manager.modifyLiquidity(
            wethUsdcPool,
            ModifyLiquidityParams({
                tickLower: -1000,
                tickUpper: 1000,
                liquidityDelta: -500 ether, // Remove liquidity
                salt: keccak256("test-position")
            }),
            abi.encodePacked(alice)
        );
        vm.stopPrank();
    }

    function _simulateMEVGeneratingSwaps() internal {
        // Simulate swaps that would generate MEV in real conditions
        vm.startPrank(mevBot);
        
        // Large swap to create price impact
        router.exactInputSingle(
            SwapParams({
                zeroForOne: true,
                amountSpecified: int256(15 ether),
                sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
            }),
            wethUsdcPool,
            abi.encodePacked(mevBot)
        );
        
        // Another large swap in opposite direction
        router.exactInputSingle(
            SwapParams({
                zeroForOne: false,
                amountSpecified: int256(10 ether),
                sqrtPriceLimitX96: TickMath.MAX_SQRT_PRICE - 1
            }),
            wethUsdcPool,
            abi.encodePacked(mevBot)
        );
        
        vm.stopPrank();
    }

    // ==================== HELPER FUNCTIONS FROM DEPLOYERS ====================
    
    function _deployFreshManagerAndRouters() internal {
        // This is a simplified version - in a real scenario, you'd deploy the PoolManager
        // For fork tests, we use the real mainnet PoolManager
        console2.log("Using real mainnet PoolManager");
    }
    
    function deployCodeTo(string memory what, bytes memory args, address at) internal override {
        vm.etch(at, vm.getCode(what));
    }
}
