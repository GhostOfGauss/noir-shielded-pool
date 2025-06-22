import { IMT } from "@zk-kit/imt";
import { poseidon2 } from "poseidon-lite";
import { stringifyWithBigInts } from "./utils";

const depth = 10;
const zeroValue = 0;
const arity = 2;

const tree = new IMT(poseidon2, depth, zeroValue, arity);

console.log(`Insert 1 at index 0`);
tree.insert(1);
console.log(`Insert 2 at index 1`);
tree.insert(2);

console.log(`Current root: ${tree.root}`);

const proof = tree.createProof(0);
console.log(`Proof for index 0: ${stringifyWithBigInts(proof)}`);
tree.verifyProof(proof);

// DEBUGGING
// Produces TSC error but the JS can be executed if you need to see the inner nodes
// console.log(`tree nodes[0] ${tree._nodes[0]}`);
// console.log(`tree nodes[1] ${stringifyWithHexBigInts(tree._nodes[1])}`);
