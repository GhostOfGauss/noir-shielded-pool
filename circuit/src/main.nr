use accumulator::Accumulator;
use keypair::SecretKey;
use merkle::{MerkleInclusionPath, MerkleTree};
use utxo::{PreUtxo, Utxo};

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

// fn main(pre: PreUtxo) -> pub Utxo {
//     Utxo::new(pre)
// }

// fn main(utxo: Utxo, sk: SecretKey) -> pub Field {
//     utxo.nullify(sk)
// }

fn main(utxo: Utxo, path: MerkleInclusionPath, root: pub Field) {
    let tree = MerkleTree::from_root(root);
    println(f"root: {root}");
    tree.contains(utxo, path);
}

// #[test]
// fn test_main() {
//     let inputs = [Asset::new(1, 3), Asset::new(1, 4)];
//     let outputs = [Asset::new(1, 2), Asset::new(1, 5)];
//     main(inputs, outputs);
// }
