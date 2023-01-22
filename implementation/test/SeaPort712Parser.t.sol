// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/SeaPort712Parser.sol";
import "src/SeaPortMock.sol";
import "test/OrderGenerator.sol";
import "forge-std/Test.sol";

contract SeaPort712ParserTest is Test, OrderGenerator {
    SeaPortMock seaPortMock;
    SeaPort712Parser seaPort712Parser;

    function setUp() public {
        seaPort712Parser = new SeaPort712Parser();
        seaPortMock = new SeaPortMock(address(seaPort712Parser));
    }

    function testEvalEIP712Buffer() view public  {
        OrderComponents memory order = generateOrder();
        string[] memory translatedSig = seaPortMock.translateSig(order);
        for (uint256 i = 0; i < translatedSig.length; i++) {
            console.log(translatedSig[i]);
        }
    }
}
