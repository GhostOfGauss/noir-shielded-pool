// Embedded curve scalar field in its
// non-native representation as limbs
// valued in the proof system scalar field.
export class SecretKey {
  constructor(
    public lo: bigint,
    public hi: bigint
  ) {}

  toCircuitInput() {
    return { lo: this.lo.toString(), hi: this.hi.toString() };
  }
}

// Embedded curve point represented
// in affine coordinates over the
// proof system scalar field.
export class PublicKey {
  constructor(
    public x: bigint,
    public y: bigint,
    public is_infinite: boolean
  ) {
    // TODO: check well-constructed
  }

  toCircuitInput() {
    return {
      x: this.x.toString(),
      y: this.y.toString(),
      is_infinite: this.is_infinite,
    };
  }

  /**
   * Derive public key from secret key
   * by multiplying generator point.
   */
  static derive(sk: SecretKey): PublicKey {
    // TODO: this is backend dependent, sometimes
    // BB uses Grumpkin, sometimes BabyJubJub as
    // embedded curve.
    throw "unimpl";
  }
}
