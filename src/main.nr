use asset::{assert_balanced_tx, Asset};

mod asset;

fn main(inputs: [Asset; 2], outputs: [Asset; 2]) {
    assert_balanced_tx(inputs, outputs);
}

#[test]
fn test_main() {
    let inputs = [Asset::new(1, 3), Asset::new(1, 4)];
    let outputs = [Asset::new(1, 2), Asset::new(1, 5)];
    main(inputs, outputs);
}
