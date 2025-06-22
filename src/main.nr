use transaction::{Transaction, TransactionPost};

mod accumulator;
mod asset;
mod keypair;
mod transaction;
mod utxo;

fn main(tx: Transaction) -> pub TransactionPost {
    TransactionPost::new(tx)
}

// #[test]
// fn test_main() {
//     let inputs = [Asset::new(1, 3), Asset::new(1, 4)];
//     let outputs = [Asset::new(1, 2), Asset::new(1, 5)];
//     main(inputs, outputs);
// }
