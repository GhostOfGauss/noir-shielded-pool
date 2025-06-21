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
pub struct Utxo<C> {
    // TODO: Seems Noir does not allow to define
    // the struct with the bound C: UtxoCommitment
    // and use the associated Output type
    // from the trait.
    commitment: Field,
}

pub trait UtxoCommitment {
    fn commit(pre: PreUtxo) -> Field;
}

impl<C> Utxo<C>
where
    C: UtxoCommitment,
{
    pub fn new(pre: PreUtxo) -> Self {
        Self { commitment: C::commit(pre) }
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

pub trait UtxoNullifier<C> {
    fn nullify(utxo: Utxo<C>, sk: SecretKey) -> Field;
}

// Placeholder for proper nullifier, simply
// reveals the Utxo commitment. Obviously
// not privacy-preserving.
pub struct DummyUtxoNullifier;

impl<C> UtxoNullifier<C> for DummyUtxoNullifier {
    fn nullify(utxo: Utxo<C>, _sk: SecretKey) -> Field {
        utxo.commitment
    }
}
