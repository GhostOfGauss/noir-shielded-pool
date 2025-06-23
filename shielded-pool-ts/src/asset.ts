import { equal } from "assert";

export class Asset {
  public id: bigint;
  public amount: bigint;

  constructor(id: bigint | number, amount: bigint | number) {
    if (typeof id === "number") {
      this.id = BigInt(id);
    } else {
      this.id = id;
    }
    if (typeof amount === "number") {
      this.amount = BigInt(amount);
    } else {
      this.amount = amount;
    }
    // TODO: same range check that circuit enforces on amount
  }

  toCircuitInput() {
    return {
      id: this.id.toString(),
      amount: this.amount.toString(),
    };
  }
}

export function assertBalanced(incoming: Asset[], outgoing: Asset[]) {
  // Like asset type:
  incoming.map((asset) => equal(asset.id, incoming[0].id));
  outgoing.map((asset) => equal(asset.id, incoming[0].id));
  // Balance
  equal(
    incoming.reduce((sum, asset) => (sum += asset.amount), 0n),
    outgoing.reduce((sum, asset) => (sum += asset.amount), 0n)
  );
}
