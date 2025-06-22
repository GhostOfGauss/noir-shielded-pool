import { UltraHonkBackend } from "@aztec/bb.js";
import { Noir } from "@noir-lang/noir_js";
import circuit from "../../circuit/target/shielded_pool.json";

// Type-widening bug causes tsc to misinterpret
// AbiType { "kind": "field" } as { kind: string }
// @ts-ignore
const noir = new Noir(circuit);
const backend = new UltraHonkBackend(circuit.bytecode);
