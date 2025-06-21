# UTXO Shielded Pool "Spec"
(More a "description" than a "spec", really)

# Protocol
Shielded pool enables creation of UTXOs without revealing their underlying asset or owner, nor which UTXOs were consumed to allow their creation.

## Asset

An `Asset` consists of an (`AssetId`, `AssetAmount`) pair. Concretely these will be modeled as field elements, with `AssetId` unconstrained and `AssetAmount` range-constrained to avoid overflow when adding assets.

Assets of the same type (*i.e.* with equal `AssetId`s) can be added, so long as the resulting amount would not exceed the maximum allowed value.

Assets are considered *equal* if they are of the same type and same amount.

## Keypair

A `Keypair` consists of a (`SecretKey`, `PublicKey`) pair. The `SecretKey` will be modeled as a field element $\mathsf{sk} \in \mathbb{F}$ and the `PublicKey` is an elliptic curve point defined by
$$ \mathsf{pk} = \mathsf{sk} \cdot g$$
where $g \in \mathbb{G}$ generates the subgroup of order $| \mathbb{F} |$.

TODO:
- ephemeral secret keys
- key hierarchy (proving, viewing keys)
- signatures

## Private UTXO
Typically a UTXO is roughly an (`Asset`, `PublicKey`) pair representing the right of the public key's owner to spend the asset.

A *private* `Utxo` consists of a commitment to such an (`Asset`, `PublicKey`) pair with respect to some cryptographic commitment function $\mathsf{COM}_{\mathsf{UTXO}}$.

To preserve privacy, commitment randomness $r \in \mathbb{F}$ makes the commitment non-deterministic with respect to the (`Asset`, `PublicKey`) pair. (Otherwise it would be possible to confirm one's guess for the values underlying the commitment.)

We define for asset $\mathsf{a}$, public key $\mathsf{pk}$ and randomness $r$ the commitment by
$$\mathsf{cm} = \mathsf{COM}_{\mathsf{UTXO}}(r, \mathsf{a}, \mathsf{pk})$$

It is useful to have a name for the data $(r, \mathsf{a}, \mathsf{pk})$, so we shall refer to this triple as a `PreUtxo`.

### Nullification: Spending a Private UTXO
On a transparent ledger, validators directly track the IDs of UTXOs to decide whether a given UTXO has been spent. The use of IDs is antithetical to a shielded pool; even if the owner and transaction amount of a UTXO were encrypted, the UTXO ID would provide a link between transactions creating and spending a given asset.

Instead, shielded pools use *nullifiers* to prevent the double-spending of assets without revealing which UTXOs make up a transaction. The nullifier is derived deterministically from the UTXO secret key. For UTXO commitment $\mathsf{cm}$ and secret key $\mathsf{sk}$, we define the nullifier $n \in \mathbb{F}$ by
$$n = \mathsf{COM}_{\mathsf{NULL}}(\mathsf{sk}, \mathsf{cm})$$
for some cryptographic commitment function $\mathsf{COM}_{\mathsf{NULL}}$.

The nullifier's important properties are:
- binding: it is bound to the secret key and UTXO commitment, preventing double-spending of the same UTXO
- hiding: it is computationally infeasible to determine either $\mathsf{sk}$ or $\mathsf{cm}$ from the nullifier's value

TODO:
- proper key hierarchy: define $n$ using a proof authorization key instead of secret key for security

## Shielded Pool
The shielded pool consists of two sets:
- UTXO set: The set of all UTXO commitments having appeared in a valid transaction (see below)
- Nullifier set: the set of all nullifiers having appeared in a valid transaction

### UTXO Set Inclusion
As we will see below, it is necessary to be able to demonstrate that a given UTXO commitment $\mathsf{cm}$ belongs to the UTXO set using ZKP. We therefore assume the UTXO set is augmented with a cryptographic accumulator (such as a Merkle tree) to enable set inclusion proofs.

## Transaction
We describe transactions and their validity conditions. (To simplify the exposition we assume a transaction consists of two incoming UTXOs and two outgoing UTXOs, but this is easily generalized.)

Informally, a transaction consists of incoming UTXOs which have not been nullified and outgoing UTXOs formed from these in a balance-preserving manner.

### Inputs
Say the inputs to the transaction are UTXOs defined by commitments
- $\mathsf{cm}_{\text{in},0}$
- $\mathsf{cm}_{\text{in},1}$

corresponding to the pre-UTXOs
- $(r_{\text{in},0}, \mathsf{a}_{\text{in},0}, \mathsf{pk}_{\text{in}})$
- $(r_{\text{in},1}, \mathsf{a}_{\text{in},1}, \mathsf{pk}_{\text{in}})$

with nullifiers
- $n_0 = \mathsf{COM}_{\mathsf{NULL}}(\mathsf{sk}_{\text{in}}, \mathsf{cm}_{\text{in},0})$
- $n_1 = \mathsf{COM}_{\mathsf{NULL}}(\mathsf{sk}_{\text{in}}, \mathsf{cm}_{\text{in},1})$

Here $(\mathsf{sk}_{\text{in}}, \mathsf{pk}_{\text{in}})$ is the keypair of the transaction Sender.

### Outputs
Denote the output UTXO commitments
- $\mathsf{cm}_{\text{out},0}$
- $\mathsf{cm}_{\text{out},1}$

corresponding to the pre-UTXOs
- $(r_{\text{out},0}, \mathsf{a}_{\text{out},0}, \mathsf{pk}_{\text{out}})$
- $(r_{\text{out},1}, \mathsf{a}_{\text{out},1}, \mathsf{pk}_{\text{out}})$

### Validity (Public)
To preserve privacy, only the following transaction data is posted to the public ledger:
- Input nullifiers $n_0, n_1$
- Output UTXO commitments $\mathsf{cm}_{\text{out},0}, \mathsf{cm}_{\text{out},1}$
- ZKP $\pi$

Validators accept the transaction if
- the input nullifiers do not already belong to the existing nullifier set
- the output UTXO commitments do not already belong to the UTXO set
- $\pi$ is a valid ZKP for the following statement:

### Validity (Private)
The remainder of the transaction validity statement requires knowledge of sensitive data that must not be posted to the public ledger. It is therefore expressed as a zero knowledge circuit and proved by the Sender in an appropriate ZKP scheme.

The circuit's private inputs are
- the Sender's keypair $(\mathsf{sk}_{\text{in}}, \mathsf{pk}_{\text{in}})$
- all assets $\mathsf{a}_{\text{in},0}, \mathsf{a}_{\text{in},1}, \mathsf{a}_{\text{out},0}, \mathsf{a}_{\text{out},1}$
- the input UTXO commitments $\mathsf{cm}_{\text{in},0}, \mathsf{cm}_{\text{in},1}$
- all randomness scalars $r$

The circuit's public inputs are the nullifiers and output UTXO commitments posted to the public ledger, as well as the current root $\mathsf{UtxoSet.root}$ of the UTXO set.

The circuit's statement is the union of:
- Asset balance: the sum of input assets (as defined above) equals the sum of output assets
- UTXO commitments well-formed: $\mathsf{cm} = \mathsf{COM}_{\mathsf{UTXO}}(r, \mathsf{a}, \mathsf{pk})$ for each input, output UTXO commitment
- input UTXO ownership: $\mathsf{pk}_{\text{in}} = \mathsf{sk}_{\text{in}} \cdot g$
- input UTXO existence: inclusion of $\mathsf{cm}_{\text{in},0}, \mathsf{cm}_{\text{in},1}$ against $\mathsf{UtxoSet.root}$
- input UTXOs nullified: $n_i = \mathsf{COM}_{\mathsf{NULL}}(\mathsf{sk}_{\text{in}}, \mathsf{cm}_{\text{in},i})$

## TODO: Encrypted Message
- required to transmit the output UTXO randomness to the Receiver, else tx's become unspendable

# Cryptography
- Commitment functions
    - UTXO commitment: curve to field hashing
    - Nullifier commitment
- Encryption
- Accumulator: Merkle tree
- Barretenberg default prover?
  - which curves?
  - curve specs
  - UltraHonk description
  - Proof data
  - verifier algorithm
  - FS hash function
