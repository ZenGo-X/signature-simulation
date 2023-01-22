// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/IEvalEIP712Buffer.sol";
import {ItemType, OrderType, OfferItem, ConsiderationItem, OrderComponents} from "src/SeaPortStructs.sol";

contract SeaPort712Parser is IEvalEIP712Buffer {
    string sigMessage =
        "This is a Seaport listing message, mostly used by OpenSea Dapp, be aware of the potential balance changes";

    struct BalanceOut {
        uint256 amount;
        address token;
    }

    struct BalanceIn {
        uint256 amount;
        address token;
    }

    function toString(uint256 value) internal pure returns (string memory str) {
        assembly {
            let m := add(mload(0x40), 0xa0)
            mstore(0x40, m)
            str := sub(m, 0x20)
            mstore(str, 0)
            let end := str
            for { let temp := value } 1 {} {
                str := sub(str, 1)
                mstore8(str, add(48, mod(temp, 10)))
                temp := div(temp, 10)
                if iszero(temp) { break }
            }
            let length := sub(end, str)
            str := sub(str, 0x20)
            mstore(str, length)
        }
    }

    function getTokenNameByAddress(address _token) private view returns (string memory) {
        if (_token == address(0)) {
            return "ETH";
        } else {
            (bool success, bytes memory returnData) = _token.staticcall(abi.encodeWithSignature("name()"));
            if (success && returnData.length > 0) {
                return string(returnData);
            } else {
                return "Unknown";
            }
        }
    }

    // need to manage array length because of the fact that default array values are 0x0 which represents 'native token'
    function getElementIndexInArray(address addressToSearch, uint256 arrayLength, address[] memory visitedAddresses)
        private
        pure
        returns (uint256)
    {
        for (uint256 i; i < arrayLength; i++) {
            if (addressToSearch == visitedAddresses[i]) {
                return i;
            }
        }
        return visitedAddresses.length + 1;
    }

    function evalEIP712Buffer(bytes memory _signature)
        public
        view
        override
        returns (string[] memory sigTranslatedMessage)
    {
        OrderComponents memory order = abi.decode(_signature, (OrderComponents));
        BalanceOut[] memory tempBalanceOut = new BalanceOut[](order.offer.length);
        BalanceIn[] memory tempBalanceIn = new BalanceIn[](order.consideration.length);
        address[] memory outTokenAddresses = new address[](order.offer.length);
        address[] memory inTokenAddresses = new address[](order.consideration.length);

        uint256 outLength;
        for (uint256 i; i < order.offer.length; i++) {
            uint256 index = getElementIndexInArray(order.offer[i].token, outLength, outTokenAddresses);
            if (index != outTokenAddresses.length + 1) {
                tempBalanceOut[index].amount += order.offer[i].startAmount;
            } else {
                outTokenAddresses[outLength] = order.offer[i].token;
                tempBalanceOut[outLength] = BalanceOut(order.offer[i].startAmount, order.offer[i].token);
                outLength++;
            }
        }

        uint256 inLength;
        for (uint256 i; i < order.consideration.length; i++) {
            if (order.offerer == order.consideration[i].recipient) {
                uint256 index = getElementIndexInArray(order.consideration[i].token, inLength, inTokenAddresses);
                if (index != inTokenAddresses.length + 1) {
                    tempBalanceIn[index].amount += order.consideration[i].startAmount;
                } else {
                    inTokenAddresses[inLength] = order.consideration[i].token;
                    tempBalanceIn[inLength] =
                        BalanceIn(order.consideration[i].startAmount, order.consideration[i].token);
                    inLength++;
                }
            }
        }

        sigTranslatedMessage = new string[](outLength + inLength + 2);
        sigTranslatedMessage[0] = sigMessage;
        sigTranslatedMessage[1] = string(abi.encodePacked("The signature is valid until ", toString(order.endTime)));
        for (uint256 i; i < inLength; i++) {
            sigTranslatedMessage[i + 2] = string(
                abi.encodePacked(
                    "You will receive ",
                    toString(tempBalanceIn[i].amount),
                    " of ",
                    getTokenNameByAddress(tempBalanceIn[i].token)
                )
            );
        }

        for (uint256 i; i < outLength; i++) {
            sigTranslatedMessage[i + inLength + 2] = string(
                abi.encodePacked(
                    "You will send ",
                    toString(tempBalanceOut[i].amount),
                    " of ",
                    getTokenNameByAddress(tempBalanceOut[i].token)
                )
            );
        }
        return (sigTranslatedMessage);
    }
}
