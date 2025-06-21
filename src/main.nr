use keypair::{Keypair, PublicKey, SecretKey};

mod asset;
mod keypair;
mod utxo;

fn main(secret: SecretKey) -> pub PublicKey {
    let keypair = Keypair::new(secret);
    keypair.public()
}

// #[test]
// fn test_main() {
//     let inputs = [Asset::new(1, 3), Asset::new(1, 4)];
//     let outputs = [Asset::new(1, 2), Asset::new(1, 5)];
//     main(inputs, outputs);
// }
