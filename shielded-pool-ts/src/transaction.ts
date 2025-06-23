import { assertBalanced } from "./asset";
import { SecretKey } from "./keypair";
import { MerkleInclusionProof, MerkleTree } from "./merkle";
import { PreUtxo, Utxo } from "./utxo";
import { strict as assert, equal } from "assert";

export class TransactionPost {
  public outgoingUtxos: Utxo[];
  public incomingNullifiers: bigint[];
  public accumulatorRoot: bigint;

  constructor(tx: Transaction, utxoAccumulator: MerkleTree) {
    // Current convention is that a tx is 2-in 2-out
    equal(tx.incomingPreUtxos.length, 2);
    equal(tx.outgoingPreUtxos.length, 2);

    // Asset balance
    assertBalanced(
      tx.incomingPreUtxos.map((utxo) => utxo.asset),
      tx.outgoingPreUtxos.map((utxo) => utxo.asset)
    );

    // Well-formed UTXO commitments
    const incomingUtxos = tx.incomingPreUtxos.map((pre) => new Utxo(pre));
    const outgoingUtxos = tx.outgoingPreUtxos.map((pre) => new Utxo(pre));

    // Incoming UTXO existence
    incomingUtxos.map((utxo, i) => {
      utxoAccumulator.verifyProof(tx.utxoInclusionWitness[i]);
      equal(utxo.commitment, tx.utxoInclusionWitness[i].leaf);
    });

    // Incoming UTXO ownership
    // TODO: Keypair derivation is unimpl

    // Incoming UTXO nullifiers
    let incomingNullifiers = incomingUtxos.map((utxo) =>
      utxo.nullify(tx.spenderSk)
    );

    this.outgoingUtxos = outgoingUtxos;
    this.incomingNullifiers = incomingNullifiers;
    this.accumulatorRoot = utxoAccumulator.root();
  }

  toCircuitInput() {
    return {
      outgoing_utxos: this.outgoingUtxos.map((utxo) => utxo.toCircuitInput()),
      incoming_nullifiers: this.incomingNullifiers.map((nullifier) =>
        nullifier.toString()
      ),
      accumulator_root: this.accumulatorRoot.toString(),
    };
  }
}

export class Transaction {
  // Natively performs all circuit checks
  constructor(
    public incomingPreUtxos: PreUtxo[],
    public outgoingPreUtxos: PreUtxo[],
    public spenderSk: SecretKey,
    public utxoAccumulatorRoot: bigint,
    public utxoInclusionWitness: MerkleInclusionProof[]
  ) {}

  toCircuitInput() {
    return {
      incoming_pre_utxos: this.incomingPreUtxos.map((pre) =>
        pre.toCircuitInput()
      ),
      outgoing_pre_utxos: this.outgoingPreUtxos.map((pre) =>
        pre.toCircuitInput()
      ),
      spender_sk: this.spenderSk.toCircuitInput(),
      utxo_accumulator_root: this.utxoAccumulatorRoot.toString(),
      utxo_inclusion_witness: this.utxoInclusionWitness.map((witness) =>
        witness.toCircuitInput()
      ),
    };
  }
}
