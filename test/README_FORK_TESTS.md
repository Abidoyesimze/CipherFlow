# CipherFlow Hook Mainnet Fork Tests

This directory contains comprehensive mainnet fork tests for the CipherFlow Hook, demonstrating real-world integration with Uniswap v4, EigenLayer AVS, and Fhenix FHE systems.

## 🎯 Overview

The CipherFlow Hook mainnet fork tests validate production-ready integration with:

- **Uniswap v4 PoolManager** - Real mainnet deployment
- **EigenLayer AVS** - MEV-resistant execution network
- **Fhenix FHE** - Confidential computation platform
- **Real MEV Patterns** - Actual sandwich attacks and arbitrage
- **Dynamic Fee Mechanisms** - Volatility-based fee adjustments

## 🚀 Quick Start

### Prerequisites

1. **RPC Endpoints**: Set up your `.env` file with mainnet RPC URLs:
```bash
# .env file
MAINNET_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_KEY
```

2. **Dependencies**: Ensure all dependencies are installed:
```bash
forge install
```

### Running Tests

#### Basic Fork Tests
```bash
forge test --match-contract CipherFlowHookForkTest
```

#### CI/CD Profile
```bash
FOUNDRY_PROFILE=forktest forge test --match-contract CipherFlowHookForkTest
```

#### Verbose Output
```bash
forge test --match-contract CipherFlowHookForkTest -vvvv
```

## 📋 Test Scenarios

### 1. Pool Initialization with MEV Protection
```solidity
function testFork_poolInitializationWithMEVProtection()
```
- Validates MEV protection configuration initialization
- Checks default volatility thresholds and fee multipliers
- Ensures proper hook permissions are set

### 2. Normal Swaps with Dynamic Fees
```solidity
function testFork_normalSwapWithDynamicFees()
```
- Tests standard swap execution through the hook
- Validates dynamic fee calculation based on market conditions
- Verifies fee data updates and volatility tracking

### 3. MEV Attack Detection
```solidity
function testFork_mevAttackDetection()
```
- Simulates coordinated sandwich attacks
- Tests rapid sequential swap detection
- Validates MEV risk scoring and response mechanisms

### 4. Large Swap Routing to AVS
```solidity
function testFork_largeSwapRoutingToAVS()
```
- Tests routing high-risk swaps to EigenLayer AVS
- Validates encrypted order submission
- Checks pool health metrics and monitoring

### 5. Encrypted Liquidity Positions
```solidity
function testFork_encryptedLiquidityPositions()
```
- Tests Fhenix FHE integration for position encryption
- Validates encrypted position creation and management
- Checks position updates and removals

### 6. Dynamic Fee Adjustments
```solidity
function testFork_dynamicFeeAdjustments()
```
- Tests fee adjustments under various market conditions
- Validates volatility-based multipliers
- Checks liquidity-based fee adjustments

### 7. Cross-Pool Arbitrage Prevention
```solidity
function testFork_crossPoolArbitragePrevention()
```
- Tests arbitrage detection across multiple pools
- Validates coordinated attack prevention
- Checks risk score elevation mechanisms

### 8. MEV Rewards Distribution
```solidity
function testFork_mevRewardsDistribution()
```
- Tests MEV extraction and redistribution to LPs
- Validates reward accumulation mechanisms
- Checks pool health metrics updates

## 🏗️ Test Architecture

### Fork Setup
- **Block Number**: 21,900,000 (Recent block with good liquidity)
- **PoolManager**: Real Uniswap v4 mainnet deployment
- **Tokens**: WETH, USDC, USDT with real whale addresses
- **Hook Address**: Calculated based on required permissions

### Test Users
- **Alice**: Normal user for standard operations
- **Bob**: Secondary user for multi-user scenarios
- **MEV Bot**: Simulates malicious actors and MEV attacks

### Token Sources
- **WETH**: Binance whale (0x28C6c06298d514Db089934071355E5743bf21d60)
- **USDC**: Binance whale (0x28C6c06298d514Db089934071355E5743bf21d60)
- **USDT**: Binance whale (0x28C6c06298d514Db089934071355E5743bf21d60)

## 🔧 Configuration

### Foundry Configuration
```toml
# foundry.toml
[rpc_endpoints]
mainnet = "${MAINNET_RPC_URL}"
sepolia = "${SEPOLIA_RPC_URL}"

[profile.forktest]
fuzz = { runs = 100 }
invariant = { runs = 50, depth = 10 }
```

### Hook Permissions
The hook is deployed with the following permissions:
- `BEFORE_INITIALIZE_FLAG`
- `AFTER_INITIALIZE_FLAG`
- `BEFORE_ADD_LIQUIDITY_FLAG`
- `AFTER_ADD_LIQUIDITY_FLAG`
- `BEFORE_REMOVE_LIQUIDITY_FLAG`
- `AFTER_REMOVE_LIQUIDITY_FLAG`
- `BEFORE_SWAP_FLAG`
- `AFTER_SWAP_FLAG`

## 📊 Expected Output

### Successful Test Run
```
=== FORKING ETHEREUM MAINNET ===
Setting up CipherFlow Hook mainnet fork tests...
WETH/USDC Pool ID: 0x...
WETH/USDT Pool ID: 0x...
=== MAINNET FORK SETUP COMPLETE ===

✓ Pool initialized with MEV protection
✓ Normal swap completed with dynamic fees
✓ MEV attack patterns detected
✓ Large swap processed with AVS integration
✓ Encrypted liquidity positions created and managed
✓ Dynamic fee adjustments working correctly
✓ Cross-pool arbitrage prevention active
✓ MEV rewards distribution system active
```

### Test Metrics
- **Pool Health**: Liquidity, volatility, MEV risk scores
- **Fee Adjustments**: Dynamic fee calculations and multipliers
- **MEV Detection**: Risk scoring and attack pattern recognition
- **AVS Integration**: Order routing and batch processing
- **FHE Operations**: Encrypted position management

## 🎯 Presentation Value

These fork tests demonstrate:

1. **Production Readiness**: Real integration with mainnet protocols
2. **MEV Protection**: Sophisticated attack detection and prevention
3. **Confidential Computing**: Fhenix FHE integration for private positions
4. **Decentralized Execution**: EigenLayer AVS for MEV-resistant swaps
5. **Dynamic Economics**: Market-responsive fee mechanisms

## 🐛 Troubleshooting

### Common Issues

1. **RPC URL Not Found**
   ```
   Skipping mainnet fork tests - MAINNET_RPC_URL not found
   ```
   **Solution**: Add `MAINNET_RPC_URL` to your `.env` file

2. **Insufficient Gas**
   ```
   Error: out of gas
   ```
   **Solution**: Increase gas limit in test configuration

3. **Token Approval Issues**
   ```
   Error: ERC20: insufficient allowance
   ```
   **Solution**: Ensure test users have sufficient token approvals

### Debug Mode
```bash
forge test --match-contract CipherFlowHookForkTest -vvvv
```

## 📈 Performance Metrics

### Test Execution Time
- **Setup**: ~30 seconds (fork creation and deployment)
- **Individual Tests**: ~10-30 seconds each
- **Full Suite**: ~5-10 minutes

### Gas Usage
- **Hook Deployment**: ~2M gas
- **Pool Initialization**: ~500K gas
- **Swap Execution**: ~200K gas
- **MEV Detection**: ~100K gas

## 🔮 Future Enhancements

1. **Fuzz Testing**: Random swap amounts and timing
2. **Invariant Testing**: Pool state consistency checks
3. **Load Testing**: High-frequency swap scenarios
4. **Integration Testing**: Multi-pool coordination
5. **Stress Testing**: Extreme market conditions

---

**Note**: These tests require active internet connection and RPC access. They validate real-world integration and are essential for production deployment validation.
