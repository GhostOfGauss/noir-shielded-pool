import { Asset } from "./asset";
import { PublicKey, SecretKey } from "./keypair";
import { poseidon3, poseidon5 } from "poseidon-lite";

export class PreUtxo {
  constructor(
    public asset: Asset,
    public pk: PublicKey,
    public randomness: bigint
  ) {}

  toCircuitInput() {
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
    this.commitment = utxoCommitment(pre);
  }

  nullify(sk: SecretKey): bigint {
    return utxoNullify(this, sk);
  }

  toCircuitInput() {
    return {
      commitment: this.commitment.toString(),
    };
  }
}

// See circuit/src/utxo.nr
export function utxoCommitment(pre: PreUtxo): bigint {
  // TODO: Domain tags
  return poseidon5([
    pre.asset.id,
    pre.asset.amount,
    pre.pk.x,
    pre.pk.y,
    pre.randomness,
  ]);
}

// See circuit/src/utxo.nr
export function utxoNullify(utxo: Utxo, sk: SecretKey): bigint {
  // TODO: Domain tags
  return poseidon3([utxo.commitment, sk.lo, sk.hi]);
}
