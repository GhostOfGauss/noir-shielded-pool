export function stringifyWithBigInts(obj: any, space = 2) {
  return JSON.stringify(
    obj,
    (_key, value) => (typeof value === "bigint" ? value.toString() : value),
    space
  );
}

export function stringifyWithHexBigInts(obj: any, space = 2) {
  return JSON.stringify(
    obj,
    (_key, value) => {
      if (typeof value === "bigint") {
        return "0x" + value.toString(16); // base 16 = hex
      }
      return value;
    },
    space
  );
}
