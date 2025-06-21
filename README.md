# Noir UTXO Shielded Pool

## Compile / Prove / Verify
### Produce `Prover.toml`
```sh
nargo check
```
or
```sh
nargo check --overwrite
```

### Generate witness:
Enter input values in `Prover.toml`, then
```sh
nargo execute
```
To produce IR use
```sh
nargo execute --print-acir > main_acir.txt
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
(save output to track circuit size)

### Verify
```sh
bb verify -k ./target/vk -p ./target/proof -i ./target/public_inputs
```
