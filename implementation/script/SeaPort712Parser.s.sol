// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "src/SeaPort712Parser.sol";
import {SeaPortMock} from "src/SeaPortMock.sol";

contract SeaPort712ParserScript is Script {
    SeaPortMock seaPortMock;
    SeaPort712Parser seaPort712Parser;

    function run() public {
        vm.startBroadcast();
        seaPort712Parser = new SeaPort712Parser();
        seaPortMock = new SeaPortMock(address(seaPort712Parser));
        vm.stopBroadcast();
    }
}
