// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IServiceManager {
    function registerOperatorToAVS(address operator, bytes calldata operatorSignature) external;
    function deregisterOperatorFromAVS(address operator) external;
}

interface ISlasher {
    function freezeOperator(address toBeFrozen) external;
}

interface IAVSDirectory {
    function operatorSaltIsSpent(address operator, bytes32 salt) external view returns (bool);
}
