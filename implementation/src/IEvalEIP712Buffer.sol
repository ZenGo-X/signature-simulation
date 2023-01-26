// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IEvalEIP712Buffer {
    struct Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }

    function evalEIP712Buffer(Domain memory domain, string memory primaryType, bytes memory signature)
        external
        view
        returns (string[] memory);
}
