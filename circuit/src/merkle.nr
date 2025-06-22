use crate::accumulator::Accumulator;
use crate::utxo::Utxo;
use poseidon::poseidon::PoseidonHasher;
use std::{default::Default, hash::Hasher};
use trees::merkle::{MembershipProver, MerkleTree as ZkKitMerkleTree, MT_Creator};

global MAX_DEPTH: u32 = 10;

// Wrap the external type to fix interface and
// generics.
pub struct MerkleTree {
    inner: ZkKitMerkleTree<Field>,
}

impl Default for MerkleTree {
    fn default() -> Self {
        MerkleTree { inner: ZkKitMerkleTree::new(merkle_tree_poseidon2_hasher) }
    }
}

impl MerkleTree {
    pub fn from_root(root: Field) -> Self {
        MerkleTree { inner: ZkKitMerkleTree::from(root, merkle_tree_poseidon2_hasher) }
    }
}

pub struct MerkleInclusionPath {
    indexes: Field,
    siblings: [Field; MAX_DEPTH],
}

impl Accumulator for MerkleTree {
    type Item = Utxo;
    type Root = Field;
    type Witness = MerkleInclusionPath;

    fn root(self) -> Self::Root {
        self.inner.root
    }

    fn contains(self, item: Self::Item, witness: Self::Witness) {
        self.inner.membership(item.commitment(), witness.indexes, witness.siblings);
    }
}

// global MERKLE_TREE_HASHER_DOMAIN_TAG: Field = Field::from_le_bytes([10, 11, 12, 13, 14]);

fn merkle_tree_poseidon2_hasher(leaves: [Field; 2]) -> Field {
    // Initialize hasher
    let mut hasher = PoseidonHasher::default();
    // hasher.write(MERKLE_TREE_HASHER_DOMAIN_TAG); // omitted for compatibility with zk-kit
    hasher.write(leaves[0]);
    hasher.write(leaves[1]);
    let result = hasher.finish();
    println(f"Poseidon hash result {result}");
    result
}
