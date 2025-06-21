/// Asset
use std::ops::Add;
use std::cmp::Eq;

pub struct Asset {
    pub id: Field,
    pub amount: Field,
}

impl Asset {
    pub fn new(id: Field, amount: Field) -> Self {
        Self { id, amount }
    }
}

impl Add for Asset {
    fn add(self, other: Self) -> Self {
        assert_eq(self.id, other.id, "Cannot add unlike assets");
        let amount = self.amount + other.amount;
        // Prevent overflow:
        amount.assert_max_bit_size::<32>();

        Self { id: self.id, amount }
    }
}

impl Eq for Asset {
    fn eq(self, other: Self) -> bool {
        let same_type = self.id == other.id;
        let same_amount = self.amount == other.amount;
        same_type & same_amount
    }
}

/// A transaction is "balanced" if its inputs and outputs have the same
/// asset IDs and total value.
pub fn assert_balanced_tx(inputs: [Asset; 2], outputs: [Asset; 2]) {
    let value_in = inputs[0] + inputs[1];
    let value_out = outputs[0] + outputs[1];
    assert_eq(value_in, value_out);
}
