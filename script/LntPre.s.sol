// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {LntPreDeposit} from "../src/LntPreDeposit.sol";
import {MockERC721} from "../src/MockERC721.sol";

contract LntPreScript is Script {
    function setUp() public {}
    function run() public {
        vm.startBroadcast();

        LntPreDeposit lnt1 = new LntPreDeposit(0x1a245cfA2515089017792D92E9d68B8F8b3691eE);
        console.log("LNT:Reppo:Premium Solver Nodes:", address(lnt1));
        LntPreDeposit lnt2 = new LntPreDeposit(0x8A1BCBd935c9c7350013786D5d1118832F10e149);
        console.log("LNT:Reppo:Standard Solver Nodes:", address(lnt2));

        vm.stopBroadcast();
    }
}
