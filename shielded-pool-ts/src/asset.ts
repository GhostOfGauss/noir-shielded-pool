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
