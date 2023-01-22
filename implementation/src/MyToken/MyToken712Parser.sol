// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/IEvalEIP712Buffer.sol";
import "src/MyToken/MyToken.sol";

contract MyToken712Parser is IEvalEIP712Buffer {
    string sigMessage =
        "This is MyToken transferWithSig message, by signing this message you are authorizing the transfer of MyToken from your account to the recipient account.";

    struct Transfer {
        address from;
        address to;
        uint256 amount;
        uint256 nonce;
        uint256 deadline;
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

    function evalEIP712Buffer(bytes memory _buffer)
        public
        view
        override
        returns (string[] memory sigTranslatedMessage)
    {
        Transfer memory transfer = abi.decode(_buffer, (Transfer));
        sigTranslatedMessage = new string[](3);
        sigTranslatedMessage[0] = sigMessage;
        sigTranslatedMessage[1] = toString(transfer.deadline);
        sigTranslatedMessage[2] = string(
            abi.encodePacked(
                "By signing this message you allow",
                toString(uint160(transfer.to)),
                "to transfer ",
                toString(transfer.amount),
                " of MyToken from your account."
            )
        );

        return sigTranslatedMessage;
    }
}
