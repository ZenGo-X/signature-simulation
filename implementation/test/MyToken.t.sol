// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {MyToken} from "src/MyToken/MyToken.sol";
import {TransferParameters} from "src/MyToken/MyTokenStructs.sol";
import {MyToken712Parser} from "src/MyToken/MyToken712Parser.sol";
import {SigUtils} from "./SigUtils.sol";

contract MyTokenTest is Test {
    MyToken myToken;
    MyToken712Parser myToken712Parser;
    SigUtils sigUtils;
    uint256 internal ownerPrivateKey;
    uint256 internal toPrivateKey;

    address internal owner;
    address internal to;

    function setUp() public {
        myToken712Parser = new MyToken712Parser();
        myToken = new MyToken(address(myToken712Parser));
        sigUtils = new SigUtils(myToken.DOMAIN_SEPARATOR());
        ownerPrivateKey = 0xA11CE;
        toPrivateKey = 0xB0B;

        owner = vm.addr(ownerPrivateKey);
        to = vm.addr(toPrivateKey);
        vm.prank(owner);
        myToken.mintToCaller();
    }

    function testNonce() public {
        uint256 currentNonce = myToken.nonces(address(this));
    }

    function test_Transfer() public {
        TransferParameters memory transfer = generateSigPayload();
        bytes32 digest = sigUtils.getTypedDataHash(transfer);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);
        console.log(myToken.balanceOf(owner));

        myToken.transferWithSig(transfer.from, transfer.to, transfer.amount, transfer.deadline, v, r, s);
        console.log(myToken.balanceOf(owner));
        assertEq(myToken.balanceOf(owner), 0);
    }

    function testEvalEIP712Buffer() view public {
        //SigUtils.Transfer memory transferPayload = generateSigPayload();
        TransferParameters memory transferPayload = generateSigPayload();
        string[] memory translatedSig = myToken.translateSig(transferPayload);
        for (uint256 i = 0; i < translatedSig.length; i++) {
            console.log(translatedSig[i]);
        }
    }

    function generateSigPayload() public view returns (TransferParameters memory transfer) {
        transfer = TransferParameters({
            from: owner,
            to: to,
            amount: myToken.balanceOf(owner),
            nonce: myToken.nonces(owner),
            deadline: block.timestamp + 1000
        });
        //transfer = My
        return transfer;
    }
}
