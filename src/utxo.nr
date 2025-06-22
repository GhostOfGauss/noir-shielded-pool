use crate::asset::Asset;
use crate::keypair::{PublicKey, SecretKey};

/// Data required to reconstruct the Utxo commitment.
/// Known to Sender and Receiver, not posted to Ledger.
pub struct PreUtxo {
    pub asset: Asset,
    pub pk: PublicKey,
    pub randomness: Field,
}

/// Private Utxo
pub struct Utxo {
    // TODO: Seems Noir does not allow to define
    // the struct with the bound C: UtxoCommitment
    // and use the associated Output type
    // from the trait.
    commitment: Field,
}

pub fn default_utxo_commit(pre: PreUtxo) -> Field {
    <DummyUtxoCommitment as UtxoCommitment>::commit(pre)
}

pub trait UtxoCommitment {
    fn commit(pre: PreUtxo) -> Field;
}

impl Utxo {
    pub fn new(pre: PreUtxo) -> Self {
        Self { commitment: default_utxo_commit(pre) }
    }
}

// Placeholder for proper cryptographic commitment
// Simply adds all data fields
pub struct DummyUtxoCommitment;

impl UtxoCommitment for DummyUtxoCommitment {
    fn commit(pre: PreUtxo) -> Field {
        pre.asset.id + pre.asset.amount + pre.pk.x + pre.pk.y + pre.randomness
    }
}

pub trait UtxoNullifier {
    fn nullify(utxo: Utxo, sk: SecretKey) -> Field;
}

// Placeholder for proper nullifier, simply
// reveals the Utxo commitment. Obviously
// not privacy-preserving.
pub struct DummyUtxoNullifier;

impl UtxoNullifier for DummyUtxoNullifier {
    fn nullify(utxo: Utxo, _sk: SecretKey) -> Field {
        utxo.commitment
    }
}
