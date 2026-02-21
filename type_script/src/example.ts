export const add = (x: number): number => x + 1;

export const double = (x: number): number => x * 2;

export const f = (x: number): number => add(double(x));

// `npx eslint src`
let y: number = 5;
export const wrong = (x: number): number => {
  y = y + x;
  return y;
}
