// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IHelloWorldServiceManager {
    event NewTaskCreated(uint32 indexed taskIndex, Task task);

    event TaskResponded(uint32 indexed taskIndex, Task task, address operator);

    struct Task {
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint32 deadline; // Block number or timestamp for expiration
        uint32 taskCreatedBlock;
    }

    function latestTaskNum() external view returns (uint32);

    function allTaskHashes(
        uint32 taskIndex
    ) external view returns (bytes32);

    function allTaskResponses(
        address operator,
        uint32 taskIndex
    ) external view returns (bytes memory);

    function createNewTask(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint32 deadline
    ) external returns (Task memory);

    function respondToTask(
        Task calldata task,
        uint32 referenceTaskIndex,
        bytes calldata signature
    ) external;

    function slashOperator(
        Task calldata task,
        uint32 referenceTaskIndex,
        address operator
    ) external;
}

// # Install dependencies
// npm install

// # Start anvil (local blockchain)
// npm run start:anvil

// # In another terminal - Deploy EigenLayer contracts
// git submodule update --init --recursive
// npm run deploy:core

// # Deploy Hello World AVS contracts  
// npm run deploy:hello-world

// # Register operator and run
// npm run start:operator
