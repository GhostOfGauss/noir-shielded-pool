use crate::accumulator::{UtxoAccumulator, UtxoAccumulatorRoot};
use crate::asset::assert_balanced_tx;
use crate::keypair::{Keypair, SecretKey};
use crate::utxo::{PreUtxo, Utxo};

/// The public data of the tx, posted
/// to the public ledger together with
/// the ZKP of tx validity.
pub struct TransactionPost {
    outgoing_utxos: [Utxo; 2],
    incoming_nullifiers: [Field; 2],
    accumulator_root: UtxoAccumulatorRoot,
}

impl TransactionPost {
    /// Produce a `TransactionPost` from raw `Transaction`
    /// data. This function enforces all private (i.e. in-circuit)
    /// transfer validity constraints.
    pub fn new(tx: Transaction) -> Self {
        // Asset balance
        assert_balanced_tx(
            tx.incoming_pre_utxos.map(|pre| pre.asset),
            tx.outgoing_pre_utxos.map(|pre| pre.asset),
        );

        // Well-formed UTXO commitments:
        let incoming_utxos = tx.incoming_pre_utxos.map(|pre| Utxo::new(pre));
        let outgoing_utxos = tx.outgoing_pre_utxos.map(|pre| Utxo::new(pre));

        // Incoming UTXO existence
        incoming_utxos.for_each(|utxo| tx.accumulator.contains(utxo));

        // Incoming UTXO ownership
        let spender_keypair = Keypair::new(tx.spender_sk);
        tx.incoming_pre_utxos.for_each(|pre| assert_eq(spender_keypair.public(), pre.pk));

        // Incoming UTXO nullifiers
        let incoming_nullifiers = incoming_utxos.map(|utxo| utxo.nullify(tx.spender_sk));

        Self { outgoing_utxos, incoming_nullifiers, accumulator_root: tx.accumulator.root() }
    }
}

/// All data required to construct a transaction,
/// known only to the Sender.
pub struct Transaction {
    incoming_pre_utxos: [PreUtxo; 2],
    outgoing_pre_utxos: [PreUtxo; 2],
    spender_sk: SecretKey,
    accumulator: UtxoAccumulator,
}
