use merkle::{MerkleInclusionPath, MerkleTree};
use accumulator::Accumulator;
use utxo::Utxo;

type Transaction = transaction::Transaction<Field, MerkleInclusionPath>;
type TransactionPost = transaction::TransactionPost<Field>;

mod accumulator;
mod asset;
mod keypair;
mod merkle;
mod transaction;
mod utxo;

fn main(tx: Transaction) -> pub TransactionPost {
    let utxo_accumulator = MerkleTree::from_root(tx.utxo_accumulator_root);
    TransactionPost::new(utxo_accumulator, tx)
}

// #[test]
// fn test_main() {
//     let inputs = [Asset::new(1, 3), Asset::new(1, 4)];
//     let outputs = [Asset::new(1, 2), Asset::new(1, 5)];
//     main(inputs, outputs);
// }
