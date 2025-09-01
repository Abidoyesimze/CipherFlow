// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";

contract SetupTest is Test {
    function testImports() public pure {
        // This test just verifies that imports work
        assert(true);
    }
}
