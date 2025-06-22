use merkle::{MerkleInclusionPath, MerkleTree};
use accumulator::Accumulator;
use utxo::Utxo;
use asset::{Asset, assert_balanced_tx};

type Transaction = transaction::Transaction<Field, MerkleInclusionPath>;
type TransactionPost = transaction::TransactionPost<Field>;

mod accumulator;
mod asset;
mod keypair;
mod merkle;
mod transaction;
mod utxo;

// fn main(tx: Transaction) -> pub TransactionPost {
//     let utxo_accumulator = MerkleTree::from_root(tx.utxo_accumulator_root);
//     TransactionPost::new(utxo_accumulator, tx)
// }

fn main(inputs: [Asset; 2], outputs: [Asset; 2]) {
    assert_balanced_tx(inputs, outputs);
}

// #[test]
// fn test_main() {
//     let inputs = [Asset::new(1, 3), Asset::new(1, 4)];
//     let outputs = [Asset::new(1, 2), Asset::new(1, 5)];
//     main(inputs, outputs);
// }
