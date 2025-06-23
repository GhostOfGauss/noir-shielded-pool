import { IMT, IMTMerkleProof } from "@zk-kit/imt";
import { strict as assert } from "assert";
import { poseidon2 } from "poseidon-lite";

// MAX_DEPTH must match circuit/merkle.nr
const MAX_DEPTH = 10;
const ZERO_VALUE = 0;
const ARITY = 2;

export class MerkleTree {
  public tree: IMT;
  constructor() {
    this.tree = new IMT(poseidon2, MAX_DEPTH, ZERO_VALUE, ARITY);
  }

  root(): bigint {
    return BigInt(this.tree.root);
  }

  insert(leaf: bigint) {
    this.tree.insert(leaf);
  }

  createProof(index: number): MerkleInclusionProof {
    return MerkleInclusionProof.fromIMTMerkleProof(
      this.tree.createProof(index)
    );
  }

  verifyProof(proof: MerkleInclusionProof): boolean {
    return this.tree.verifyProof(proof.toIMTMerkleProof());
  }
}

// Corresponds to the type expected by
// circuit/merkle.nr
export class MerkleInclusionProof {
  // These fields are not part of the circuit type,
  // but are needed for native verification.
  root: bigint;
  leaf: bigint;
  leafIndex: number;
  constructor(
    public indexes: bigint,
    public siblings: bigint[],
    root: bigint,
    leaf: bigint,
    leafIndex: number
  ) {
    this.root = root;
    this.leaf = leaf;
    this.leafIndex = leafIndex;

    // Size checks
    assert(
      siblings.length === MAX_DEPTH,
      `Siblings has length ${siblings.length}, expect ${MAX_DEPTH}`
    );
    assert(indexes < 1 << MAX_DEPTH, `index too large for tree size`);
  }

  static fromIMTMerkleProof(proof: IMTMerkleProof): MerkleInclusionProof {
    // Noir circuit packs the index bits into a field element
    const indexes = fromLeBits(proof.pathIndices);
    return new MerkleInclusionProof(
      indexes,
      proof.siblings,
      proof.root,
      proof.leaf,
      proof.leafIndex
    );
  }

  toIMTMerkleProof(): IMTMerkleProof {
    return {
      root: this.root,
      leaf: this.leaf,
      leafIndex: this.leafIndex,
      siblings: this.siblings,
      pathIndices: toLeBits(this.indexes),
    };
  }

  toCircuitInput() {
    return {
      indexes: this.indexes.toString(),
      siblings: this.siblings.map((s) => s.toString()),
    };
  }
}

function fromLeBits(bits: number[]): bigint {
  return bits.reduce((acc, bit, i) => {
    assert(bit * (1 - bit) === 0, "non-boolean value");
    return acc | (BigInt(bit ? 1 : 0) << BigInt(i));
  }, 0n);
}

function toLeBits(packed: bigint): number[] {
  const bits = new Array(MAX_DEPTH).fill(0);
  for (let i = 0; i < MAX_DEPTH; i++) {
    bits[i] = Number((packed >> BigInt(i)) & 1n);
  }
  return bits;
}
