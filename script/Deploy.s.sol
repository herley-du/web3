// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "../src/MyToken.sol";
import "forge-std/Script.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();
        new MyToken(1000000000000000000000); // 1000 * 1e18
        vm.stopBroadcast();
    }
}
