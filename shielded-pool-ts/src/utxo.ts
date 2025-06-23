import { Asset } from "./asset";
import { PublicKey } from "./keypair";
import { poseidon5 } from "poseidon-lite";

export class PreUtxo {
  constructor(
    public asset: Asset,
    public pk: PublicKey,
    public randomness: bigint
  ) {}

  toCircuitInputs() {
    return {
      asset: this.asset.toCircuitInput(),
      pk: this.pk.toCircuitInput(),
      randomness: this.randomness.toString(),
    };
  }
}

export class Utxo {
  commitment: bigint;

  constructor(pre: PreUtxo) {
    // TODO: Domain tags
    this.commitment = utxoCommitment(pre);
  }

  toCircuitInputs() {
    return {
      commitment: this.commitment.toString(),
    };
  }
}

// See circuit/src/utxo.nr
export function utxoCommitment(pre: PreUtxo): bigint {
  return poseidon5([
    pre.asset.id,
    pre.asset.amount,
    pre.pk.x,
    pre.pk.y,
    pre.randomness,
  ]);
}
