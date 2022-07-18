pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    component poseidon[2**n - 1];

    var h = 0;

    for(var i = n; i > 0; i--) {
        for(var j = 0; j < 2**(i - 1); j++) {
            poseidon[h] = Poseidon(2);
            if(i == n) {
                poseidon[h].inputs[0] <== leaves[2*j];
                poseidon[h].inputs[1] <== leaves[2*j + 1];
            } else {
                poseidon[h].inputs[0] <== poseidon[h - 2**i].out;
                poseidon[h].inputs[1] <== poseidon[h - 2**i + 1].out;
            }
            h += 1;
        }         
    }
    root <== poseidon[2**n - 2].out;
}


template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path

    component poseidon[n];
    
    for(var i = 0; i < n; i++) {
        poseidon[i] = Poseidon(2);
       
        var current = i == 0 ? leaf : poseidon[i - 1].out;

        poseidon[i].inputs[0] <== current + path_index[i]*(path_elements[i] - current);
        poseidon[i].inputs[1] <== path_elements[i] + path_index[i]*(current - path_elements[i]);
    }

    root <== poseidon[n - 1].out;   
}