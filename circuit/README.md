# Noir UTXO Shielded Pool
Noir circuit for proving the validity of a transaction in a shielded pool (see [spec](./spec.md)).

## Compile / Prove / Verify
### Produce `Prover.toml`
```sh
nargo check --overwrite
```

### Produce ABI
```sh
nargo compile
```

### Generate witness:
Enter input values in `Prover.toml`, then
```sh
nargo execute
```
To produce IR use
```sh
nargo execute --print-acir > acir/main_acir.txt
```
For logging to display use
```sh
 nargo execute --debug-comptime-in-file shielded_pool/src/main.nr
 ```

### Prove
(with Barretenberg defaults:)
```sh
bb prove -b ./target/shielded_pool.json -w ./target/shielded_pool.gz -o ./target -v
```

### Generate VK
```sh
bb write_vk -b ./target/shielded_pool.json -o ./target 2>&1 | tee vk_gen.log
```
(output contains circuit size)

### Verify
```sh
bb verify -k ./target/vk -p ./target/proof -i ./target/public_inputs
```
