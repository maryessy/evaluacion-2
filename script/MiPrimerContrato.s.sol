// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {MiPrimerToken} from "../src/MiPrimerToken.sol";

contract CounterScript is Script {
    MiPrimerToken token;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        token = new MiPrimerToken();
        token.mint(msg.sender, 1000000 * 10 ** 18);

        vm.stopBroadcast();
    }
}
