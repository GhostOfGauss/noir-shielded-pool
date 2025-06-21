use std::embedded_curve_ops::{EmbeddedCurvePoint, EmbeddedCurveScalar, fixed_base_scalar_mul};

pub type SecretKey = EmbeddedCurveScalar;
pub type PublicKey = EmbeddedCurvePoint;

pub struct Keypair {
    secret: SecretKey,
    public: PublicKey,
}

impl Keypair {
    /// Construct valid keypair with `pk = sk * g`,
    /// where `g` is the generator of the embedded curve.
    pub fn new(secret: SecretKey) -> Self {
        Self { secret, public: fixed_base_scalar_mul(secret) }
    }

    /// Return the public key
    pub fn public(self) -> PublicKey {
        self.public
    }
}
