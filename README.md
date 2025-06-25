# Multi-Asset Shielded Pool

Enables private UTXO transfers on a public ledger using ZKP to prove transaction validity.

## Circuit
Noir circuits implementing a simplified shielded pool. See [spec](circuit/spec.md) for details and [README](circuit/README.md) for instructions.

(These circuits are unaudited and should not be used in production.)

## Shielded Pool TS

(The beginnings of) a TS library for interacting with the shielded pool, *e.g.* as a validator or wallet. See [README](shielded-pool-ts/README.md) for instructions.

## Unimplemented:
### Encrypted note:
A proper implementation would include encrypted notes containing the asset information and UTXO commitment randomness, which the Receiver will need in order to later spend the UTXO.

For now we'll pretend that Sender/Receiver have a private communication channel.

### Ephemeral Keys
Each transaction ought to be formed using ephemeral keys derived from the original keypair. This adds an additional layer of privacy, as one can no longer observe the same public key appearing in multiple transactions.

### Proof Authorization Keys
A key derived from the secret key that allows a trusted third-party to produce proofs on one's behalf, but does not grant final signing authority. This key would be sent, for example, from a hardware wallet to a user's computer to produce the ZKP. The transaction post is then signed by the hardware wallet before being sent to the ledger.

### Viewing Keys
Yet another step in the key hierarchy, the viewing key enables third-party auditors to decrypt the encrypted notes but does not grant proof authorization or signing authority. This key would be shared, for example, with auditors for compliance.

### Public Assets
Currently all UTXOs are private, but of course a proper implementation would support transactions containing a mix of private and public assets. Otherwise it's hard to imagine how an asset would ever enter the shielded pool to begin with...
