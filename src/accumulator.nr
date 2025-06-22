pub trait Accumulator {
    /// Can be inserted into accumulator
    type Item;
    /// Proves inclusion of item against root
    type Witness;
    /// Accumulator root
    type Root;

    /// Return the current accumulator root.
    fn root(self) -> Self::Root;

    /// Check inclusion proof against root.
    fn contains(self, item: Self::Item, witness: Self::Witness);
}
