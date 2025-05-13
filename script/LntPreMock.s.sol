// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {LntPreDeposit} from "../src/LntPreDeposit.sol";
import {MockERC721} from "../src/MockERC721.sol";

contract LntPreScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        MockERC721 nft = new MockERC721("Moc721", "M721");
        LntPreDeposit lnt = new LntPreDeposit(address(nft));
        console.log("MockERC721:", address(nft));
        console.log("LntPreDeposit:", address(lnt));
        vm.stopBroadcast();
    }
}
