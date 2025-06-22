use crate::utxo::Utxo;

// Note: The realized accumulator is not part of
// the circuit logic, it is held by validators.
pub struct UtxoAccumulator {
    root: UtxoAccumulatorRoot,
}

// UtxoAccumulator can hold 2**ACCUMULATOR_DEPTH Utxo's
global ACCUMULATOR_DEPTH: u32 = 10;

pub type UtxoInclusionWitness = [(Field, bool); ACCUMULATOR_DEPTH];

pub type UtxoAccumulatorRoot = Field;

impl UtxoAccumulator {
    /// Check a UTXO against its inclusion witness.
    /// This function constrains the UTXO to belong to
    /// an accumulator with given root.
    pub fn contains(self, utxo: Utxo, inclusion_witness: UtxoInclusionWitness) {
        // TODO
    }

    pub fn root(self) -> UtxoAccumulatorRoot {
        self.root
    }
}
