import { UltraHonkBackend } from "@aztec/bb.js";
import { Noir } from "@noir-lang/noir_js";
import circuit from "../../circuit/target/shielded_pool.json";
import { Asset } from "./asset";

// Type-widening bug causes tsc to misinterpret
// AbiType { "kind": "field" } as { kind: string }
// @ts-ignore
const noir = new Noir(circuit);
const backend = new UltraHonkBackend(circuit.bytecode);

// Construct input data
const incomingAssets: Asset[] = [
  {
    id: 1,
    amount: 3,
  },
  {
    id: 1,
    amount: 7,
  },
];

const outgoingAssets: Asset[] = [
  {
    id: 1,
    amount: 2,
  },
  {
    id: 1,
    amount: 8,
  },
];

async function main() {
  const witnessStart = performance.now();
  const { witness } = await noir.execute({
    inputs: incomingAssets,
    outputs: outgoingAssets,
  });
  const witnessEnd = performance.now();
  console.log(`Witness Generation took ${witnessEnd - witnessStart}ms`);
  // console.log(`Generated witness: ${JSON.stringify(witness, undefined, 2)}`);

  const proofStart = performance.now();
  const proof = await backend.generateProof(witness);
  const proofEnd = performance.now();
  console.log(`Proof Generation took ${proofEnd - proofStart}ms`);
  // console.log(`Generated proof: ${JSON.stringify(proof, undefined, 2)}`);

  const valid = await backend.verifyProof(proof);
  if (!valid) {
    throw "Invalid proof was generated";
  }
  console.log(`Proof is valid`);

  backend.destroy();
}

main().catch(console.error);
