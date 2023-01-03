// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/IEvalEIP712Buffer.sol";
import {ItemType, OrderType, OfferItem, ConsiderationItem, OrderComponents } from "src/SeaPortStructs.sol";

contract SeaPortMock {
    address public immutable eip712TransalatorContract;

    constructor(address _translator) {
        eip712TransalatorContract = _translator;
    }

    // SeaPort logic

    function translateSig(OrderComponents memory order) public view returns (string[] memory) {
        bytes memory encodedOrder = abi.encode(order);
        return IEvalEIP712Buffer(eip712TransalatorContract).evalEIP712Buffer(encodedOrder);
    }
}
