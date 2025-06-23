use merkle::{MerkleInclusionPath, MerkleTree};

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
