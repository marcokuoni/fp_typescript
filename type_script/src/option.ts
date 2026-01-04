export type Option<A> = { _tag: "Some"; value: A } | { _tag: "None" };

export const some = <A>(value: A): Option<A> => ({ _tag: "Some", value });
export const none = <A = never>(): Option<A> => ({ _tag: "None" });

export const map =
  <A, B>(f: (a: A) => B) =>
  (oa: Option<A>): Option<B> =>
    oa._tag === "Some" ? some(f(oa.value)) : none();

export const flatMap =
  <A, B>(f: (a: A) => Option<B>) =>
  (oa: Option<A>): Option<B> =>
    oa._tag === "Some" ? f(oa.value) : none();

export const getOrElse =
  <A>(fallback: A) =>
  (oa: Option<A>): A =>
    oa._tag === "Some" ? oa.value : fallback;

// A tiny safe parse function to test with
export const parseIntOption = (s: string): Option<number> => {
  const n = Number.parseInt(s, 10);
  return Number.isNaN(n) ? none() : some(n);
};

// Example pipeline: "string -> Option<number> -> Option<number> -> number"
export const safeHalfFromString = (s: string): number =>
  getOrElse(0)(map((n: number) => n / 2)(parseIntOption(s)));
