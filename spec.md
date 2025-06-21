# UTXO Shielded Pool "Spec"
(More a "description" than a "spec", really)

# Protocol
Shielded pool enables creation of UTXOs without revealing their underlying asset or owner, nor which UTXOs were consumed to allow their creation.

## Asset

An `Asset` consists of an (`AssetId`, `AssetAmount`) pair. Concretely these will be modeled as field elements, with `AssetId` unconstrained and `AssetAmount` range-constrained to avoid overflow when adding assets.

`Asset`s of the same type (*i.e.* with equal `AssetId`s) can be added, so long as the resulting amount would not exceed the maximum allowed value.

`Asset`s are considered *equal* if they are of the same type and same amount.

# Cryptography
- Barretenberg default prover?
  - which curves?
  - curve specs
  - UltraHonk description
  - Proof data
  - verifier algorithm
  - FS hash function
