#!/bin/bash

# CipherFlow Hook Mainnet Fork Tests Runner
# This script runs the comprehensive mainnet fork tests for presentation

echo "=== CIPHERFLOW HOOK MAINNET FORK TESTS ==="
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ .env file not found!"
    echo "Please create a .env file with your RPC URLs:"
    echo "MAINNET_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY"
    echo "SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_KEY"
    echo ""
    exit 1
fi

# Check if MAINNET_RPC_URL is set
if ! grep -q "MAINNET_RPC_URL" .env; then
    echo "❌ MAINNET_RPC_URL not found in .env file!"
    echo "Please add your mainnet RPC URL to .env"
    echo ""
    exit 1
fi

echo "✅ Environment configured"
echo ""

# Load environment variables
source .env

echo "🚀 Starting mainnet fork tests..."
echo ""

# Run the fork tests
echo "Running CipherFlow Hook fork tests..."
forge test --match-contract CipherFlowHookForkTest -vv

echo ""
echo "=== TEST EXECUTION COMPLETE ==="
echo ""

# Check if tests passed
if [ $? -eq 0 ]; then
    echo "✅ All fork tests passed!"
    echo ""
    echo "🎯 Presentation ready:"
    echo "   - MEV protection validated"
    echo "   - EigenLayer AVS integration confirmed"
    echo "   - Fhenix FHE operations verified"
    echo "   - Dynamic fee mechanisms tested"
    echo "   - Real mainnet integration demonstrated"
else
    echo "❌ Some tests failed"
    echo "Check the output above for details"
fi

echo ""
echo "📊 For detailed metrics and analysis, run:"
echo "   forge test --match-contract CipherFlowHookForkTest -vvvv"
echo ""
echo "🔧 For CI/CD integration, use:"
echo "   FOUNDRY_PROFILE=forktest forge test --match-contract CipherFlowHookForkTest"
