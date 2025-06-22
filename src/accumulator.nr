use crate::utxo::Utxo;

pub struct UtxoAccumulator;

pub type UtxoAccumulatorRoot = Field;

impl UtxoAccumulator {
    pub fn contains(self, utxo: Utxo) {
        // Asserts utxo is contained in self.
    }
    pub fn root(self) -> UtxoAccumulatorRoot {
        // TODO
        Field::default()
    }
}
