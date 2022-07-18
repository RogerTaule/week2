//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {PoseidonT3} from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity

import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    uint256 constant n = 3;

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        for (uint256 i = 0; i < 2**n; ++i) {
            hashes.push(0);
        }

        uint256 init = 0;

        //Initialize everything else
        for (uint256 i = 3; i > 0; --i) {
            for (uint256 j = 0; j < 2**i; j += 2) {
                uint256 hashedValue = PoseidonT3.poseidon(
                    [hashes[init + j], hashes[init + j + 1]]
                );
                hashes.push(hashedValue);
            }

            init += 2**i;
        }

        root = hashes[2**(n + 1) - 2];
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree

        require(index < 2**n, "All leaves are fulfilled");
        hashes[index] = hashedLeaf;

        uint256 pos = index;
        index += 1;

        uint256 init = 0;
        uint256 hashedValue = 0;

        for (uint256 i = n; i > 0; --i) {
            if ((pos + 1) % 2 == 0) {
                hashedValue = PoseidonT3.poseidon(
                    [hashes[pos - 1], hashes[pos]]
                );
            } else {
                hashedValue = PoseidonT3.poseidon(
                    [hashes[pos], hashes[pos + 1]]
                );
            }

            pos = init + 2**i + ((pos - init) / 2);
            hashes[pos] = hashedValue;

            init += 2**i;
        }

        root = hashes[2**(n + 1) - 2];

        return root;
    }

    function verify(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[1] memory input
    ) public view returns (bool) {
        // [assignment] verify an inclusion proof and check that the proof root matches current root
        bool verifyInclusion = verifyProof(a, b, c, input);
        bool verifyRoot = input[0] == root;
        return verifyRoot && verifyInclusion;
    }

    function tryPoseidon() public pure returns (uint256) {
        return PoseidonT3.poseidon([uint256(4), uint256(5)]);
    }
}
