use merkle::{MerkleInclusionPath, MerkleTree};

type Transaction = transaction::Transaction<MerkleInclusionPath>;
type TransactionPost = transaction::TransactionPost<Field>;

mod accumulator;
mod asset;
mod keypair;
mod merkle;
mod transaction;
mod utxo;

fn main(tx: Transaction, utxo_accumulator_root: pub Field) -> pub TransactionPost {
    let utxo_accumulator = MerkleTree::from_root(utxo_accumulator_root);
    TransactionPost::new(utxo_accumulator, tx)
}
