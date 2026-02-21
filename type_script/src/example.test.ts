
import { describe, it, expect } from "vitest";
import {
  add,
  double,
  f,
  add5
} from "./example";

describe("pure function", () => {
  it("add", () => {
    expect(add(1)).toEqual(2);
  });

  it("double", () => {
    expect(double(2)).toEqual(4);
  });

  it("composition", () => {
    expect(f(5)).toEqual(11);
  });

  it("add5", () => {
    expect(add5(3)).toEqual(8);
  });
});
