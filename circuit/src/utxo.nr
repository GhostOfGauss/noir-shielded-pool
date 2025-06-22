use crate::asset::Asset;
use crate::keypair::{PublicKey, SecretKey};
use poseidon::poseidon2::Poseidon2Hasher;
use std::default::Default;
use std::hash::Hasher;

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

impl Utxo {
    pub fn new(pre: PreUtxo) -> Self {
        Self { commitment: default_utxo_commit(pre) }
    }

    pub fn nullify(self, sk: SecretKey) -> Field {
        default_utxo_nullifier(self, sk)
    }

    pub fn commitment(self) -> Field {
        self.commitment
    }
}

pub fn default_utxo_commit(pre: PreUtxo) -> Field {
    <Poseidon2UtxoCommitment as UtxoCommitment>::commit(pre)
}

pub fn default_utxo_nullifier(utxo: Utxo, sk: SecretKey) -> Field {
    <Poseidon2UtxoNullifier as UtxoNullifier>::nullify(utxo, sk)
}

pub trait UtxoCommitment {
    fn commit(pre: PreUtxo) -> Field;
}

// Placeholder for proper cryptographic commitment
// Simply adds all data fields
pub struct DummyUtxoCommitment;

impl UtxoCommitment for DummyUtxoCommitment {
    fn commit(pre: PreUtxo) -> Field {
        pre.asset.id + pre.asset.amount + pre.pk.x + pre.pk.y + pre.randomness
    }
}

/// Use Poseidon2 hasher to commit to
/// pre-UTXO data.
pub struct Poseidon2UtxoCommitment;

global UTXO_COMMIT_DOMAIN_TAG: Field = Field::from_le_bytes([0, 1, 2, 3, 4]);

impl UtxoCommitment for Poseidon2UtxoCommitment {
    fn commit(pre: PreUtxo) -> Field {
        // Initialize hasher
        let mut hasher = Poseidon2Hasher::default();
        hasher.write(UTXO_COMMIT_DOMAIN_TAG);
        // Absorb pre-UTXO data
        hasher.write(pre.asset.id);
        hasher.write(pre.asset.amount);
        hasher.write(pre.pk.x);
        hasher.write(pre.pk.y);
        hasher.write(pre.randomness);

        hasher.finish()
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

pub struct Poseidon2UtxoNullifier;

global UTXO_NULLIFY_DOMAIN_TAG: Field = Field::from_le_bytes([5, 6, 7, 8, 9]);

impl UtxoNullifier for Poseidon2UtxoNullifier {
    fn nullify(utxo: Utxo, sk: SecretKey) -> Field {
        // Initialize hasher
        let mut hasher = Poseidon2Hasher::default();
        hasher.write(UTXO_NULLIFY_DOMAIN_TAG);
        // Absorb pre-UTXO data
        hasher.write(utxo.commitment);
        hasher.write(sk.lo);
        hasher.write(sk.hi);

        hasher.finish()
    }
}
