use crate::accumulator::Accumulator;
use crate::asset::assert_balanced_tx;
use crate::keypair::{Keypair, SecretKey};
use crate::utxo::{PreUtxo, Utxo};

/// The public data of the tx, posted
/// to the public ledger together with
/// the ZKP of tx validity.
pub struct TransactionPost<R> {
    outgoing_utxos: [Utxo; 2],
    incoming_nullifiers: [Field; 2],
    accumulator_root: R,
}

impl<R> TransactionPost<R> {
    /// Produce a `TransactionPost` from raw `Transaction`
    /// data. This function enforces all private (i.e. in-circuit)
    /// transfer validity constraints.
    pub fn new<A, W>(utxo_accumulator: A, tx: Transaction<R, W>) -> Self
    where
        A: Accumulator<Item = Utxo, Root = R, Witness = W>,
        R: std::cmp::Eq,
    {
        // Asset balance
        assert_balanced_tx(
            tx.incoming_pre_utxos.map(|pre| pre.asset),
            tx.outgoing_pre_utxos.map(|pre| pre.asset),
        );

        // Well-formed UTXO commitments:
        let incoming_utxos = tx.incoming_pre_utxos.map(|pre| Utxo::new(pre));
        let outgoing_utxos = tx.outgoing_pre_utxos.map(|pre| Utxo::new(pre));

        // Incoming UTXO existence
        incoming_utxos.for_eachi(|i, utxo| {
            utxo_accumulator.contains(utxo, tx.utxo_inclusion_witness[i])
        });
        assert_eq(utxo_accumulator.root(), tx.utxo_accumulator_root);

        // Incoming UTXO ownership
        let sender_keypair = Keypair::new(tx.sender_sk);
        tx.incoming_pre_utxos.for_each(|pre| assert_eq(sender_keypair.public(), pre.pk));

        // Incoming UTXO nullifiers
        let incoming_nullifiers = incoming_utxos.map(|utxo| utxo.nullify(tx.sender_sk));

        Self { outgoing_utxos, incoming_nullifiers, accumulator_root: tx.utxo_accumulator_root }
    }
}

/// All data required to construct a transaction,
/// known only to the Sender.
pub struct Transaction<R, W> {
    pub incoming_pre_utxos: [PreUtxo; 2],
    pub outgoing_pre_utxos: [PreUtxo; 2],
    pub sender_sk: SecretKey,
    pub utxo_accumulator_root: R,
    pub utxo_inclusion_witness: [W; 2],
}
