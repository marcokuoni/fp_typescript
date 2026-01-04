import { describe, it, expect } from "vitest";
import {
  some,
  none,
  map,
  flatMap,
  parseIntOption,
  safeHalfFromString,
} from "./option";

describe("Option functional primitives", () => {
  it("map transforms Some", () => {
    expect(map((x: number) => x + 1)(some(1))).toEqual(some(2));
  });

  it("map leaves None unchanged", () => {
    expect(map((x: number) => x + 1)(none<number>())).toEqual(none());
  });

  it("flatMap chains computations", () => {
    const nonZero = (n: number) => (n === 0 ? none<number>() : some(10 / n));
    expect(flatMap(nonZero)(some(2))).toEqual(some(5));
    expect(flatMap(nonZero)(some(0))).toEqual(none());
  });

  it("parseIntOption parses valid ints", () => {
    expect(parseIntOption("42")).toEqual(some(42));
    expect(parseIntOption("nope")).toEqual(none());
  });

  it("safeHalfFromString gives half or 0 on invalid", () => {
    expect(safeHalfFromString("10")).toBe(5);
    expect(safeHalfFromString("wat")).toBe(0);
  });
});
