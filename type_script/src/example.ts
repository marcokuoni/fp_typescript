export const add = (x: number): number => x + 1;

export const double = (x: number): number => x * 2;

export const f = (x: number): number => add(double(x));

// `npx eslint src`
let y: number = 5;
export const wrong = (x: number): number => {
  y = y + x;
  return y;
}


// HOF

// const makeAdder = (a: number): ((b: number) => number) =>
//   (b: number) => a + b;

//---

// type UnaryNumberFn = (x: number) => number;
//
// const makeAdder = (a: number): UnaryNumberFn =>
//   (b: number) => a + b;

//---

const makeOperator =
  <T>(op: (a: T, b: T) => T) =>
  (a: T) =>
  (b: T) =>
    op(a, b);

const makeAdder = makeOperator<number>((a, b) => a + b);

export const add5 = makeAdder(5);
add5(3); // 8

// Haskell
// makeAdder :: Num a => a -> a -> a
// makeAdder a b = a + b
//
// Maybe closest in TypeScript
// const makeAdder: (a: number) => (b: number) => number =
//  a => b => a + b;
