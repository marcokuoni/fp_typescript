---
theme: bespoke
paginate: true
---

# Functional Programming in TypeScript

- From Mathematical Concept
- Over Haskell
- To TypeScript

-> Pls Download: <https://github.com/marcokuoni/fp_typescript>

---

# Agenda

- What is Functional Programming (concept overview)
- Mathematical roots (functions, composition, purity)
- Haskell as a “pure model”
- TypeScript applied examples
- Hands-on exercises throughout

---

# Function Programming Definition

- Immutable Data
- Pure Functions
  - No State (Output depends on Input and internal Algo)
  - No Side Effects (No Read or Write to outside World)

---

# Warm-Up: What is Functional Programming?

- When does debugging become painful in large TS projects?
- What makes code hard to reason about?
- Have you used map/filter/reduce?

<!--
Wenn Zustand überall mutiert wird und man nicht mehr weiss, wer etwas wann verändert hat
Wenn Funktionen versteckte Seiteneffekte haben (DB-Writes, HTTP-Calls, globale Variablen)
Wenn Debugging nur noch mit Breakpoints und Logs möglich ist, statt durch Lesen des Codes
Wenn Fehler zeitlich oder kontextabhängig sind („tritt nur in Prod auf“)

Implizite Abhängigkeiten (z.B. globale Konfiguration, Singletons)
Funktionen, die mehr als eine Sache tun
Mutation von Datenstrukturen, die an mehreren Orten verwendet werden
Unklare Datenflüsse („woher kommt dieser Wert eigentlich?“)
Unterschiedliches Verhalten je nach Ausführungsreihenfolge

keine Mutation
Fokus auf was passiert, nicht wie
Funktionen als zentrale Bausteine
-->

---

- side effects
- hidden state
- unclear data flow
- mutation

## 📌 Core idea

**Functional Programming = programming with mathematics as the design language.**
You transform values with functions, avoid surprises, and keep everything explicit.

---

# 2. Math Foundations

## 2.1 What is a function?

A function is:

- a mapping from inputs to outputs,
- deterministic: `f(x)` always returns the same `y`,
- total: defined for all valid inputs (we’ll relax this later).

**Example:**
`f(x) = x + 1`

---

**👥 Micro-exercise 1:**
Is this a function in the mathematical sense?

- `g(x) = random number`
- `h(x) = 1 / x`

Discuss determinism + domain problems (Option, Maybe, ...).

<!--
Das verletzt Determinismus (gleicher input immer gleiches output)
für x = 0 nicht definiert
f: R \ {0} -> R
-->

---

## 2.2 Composition

Mathematically:

```
(f ∘ g)(x) = f(g(x))
```

### Demonstrate

```
g(x) = x * 2
f(x) = x + 1

(f ∘ g)(3) = f(g(3)) = f(6) = 7
```

---

👥 **Micro-exercise 2:**
Given
`a(x)=x−3` and `b(x)=x²`
What is `(a ∘ b)(4)`?

<!-- 13 -->

---

## 2.3 Purity & Referential Transparency

### Definition

A function is **pure** if:

- same inputs → same output
- no side effects (no I/O, no mutation, no random, no time, no state)

---

### Show non-pure JS example

```ts
let counter = 0;
function inc() {
  return counter++;
}
```

Show pure version:

```ts
const inc = (x: number) => x + 1;
```

### Why it matters

- predictable
- testable
- composable
- no hidden surprises

<!-- type input output magic -->

---

👥 **Micro-exercise 3:**
Which of these is pure?

```ts
const a = (x: number) => x * x;
const b = (x: string) => {
  console.log(x);
  return x;
};
const c = (x: string) => Date.now();
```

---

## 2.4 Higher-Order Functions

A function that takes functions as arguments or returns functions.

**Example:**

```js
const apply = (f, x) => f(x);
const apply = (f) => (x) => f(x); //currified
```

```ts
const apply =
  <A, B>(f: (x: A) => B) =>
  (x: A): B =>
    f(x);
```

```ts
const double = (n: number): number => n * 2;
const result = apply(double)(5); // 10
```

---

# 3. Haskell as a Model of Pure FP

Why Haskell is useful:

- everything is pure
- types guide reasoning
- mathematical feel

No need to know syntax; We check how FP looks _clean_

---

## 3.1 Basic Haskell functions

```haskell
add1 x = x + 1
double x = x * 2
```

Composition:

```haskell
f = add1 . double
```

Demonstrate and try in GHCI:

```haskell
f 3
-- 7
```

---

## 3.2 Immutability

In Haskell:

```haskell
x = 3
y = x + 1
```

Variables cannot be reassigned.

- reasoning becomes algebraic.

---

## 3.3 Type signatures

```haskell
add1 :: Int -> Int
add1 x = x + 1
```

You can treat the type like a function arrow.

---

## 3.4 Pattern matching & recursion

```haskell
fact 0 = 1
fact n = n * fact (n - 1)
```

Why this is pure?
How to do a pure loop?

---

Because recursion is just mathematical induction.

👥 **Exercise 4:**
Write a pure function of your own in Haskell syntax:

```
square x = ?
```

---

# 4. Going from Haskell to TypeScript

---

## 4.1 Pure functions in TS

```ts
const add1 = (x: number): number => x + 1;
const double = (x: number): number => x * 2;
const f = (x: number) => add1(double(x));
```

---

## 4.2 Higher-order functions in TS

### Example: function factory

```ts
const makeAdder = (a: number) => (b: number) => a + b;
const add5 = makeAdder(5);
add5(3); // 8
```

Can we make this generic?

👥 **Exercise 5:**
Write a HOF:

```
const applyTwice = ???;
```

<!-- ``` -->
<!-- const applyTwice = -->
<!--   <T>(f: (x: T) => T) => -->
<!--   (x: T): T => -->
<!--     f(f(x)); -->
<!-- ``` -->

---

## 4.3 map/filter/reduce as composition

Tie it back to mathematics:

```ts
const nums = [1, 2, 3, 4];

const result = nums
  .map((x) => x + 1)
  .filter((x) => x % 2 === 0)
  .reduce((sum, x) => sum + x, 0);
```

Ask: why is this easy to reason about?
Because each step is _pure_ and _composable_.

---

## 4.4 Immutability in JS/TS

```
const arr2 = [...arr1, 4];
```

How to avoid mutation traps.

---

# 5. Mini-Workshop: Build a Pure Pipeline

### 🛠️ Task

Given a list of numbers:

1. Remove odd numbers
2. Square the even numbers
3. Sum them
4. Keep everything pure

### Haskell version

```haskell
pipeline xs = sum (map (^2) (filter even xs))
```

<!-- ### TypeScript version -->
<!---->
<!-- ```ts -->
<!-- const pipeline = (xs: number[]) => -->
<!--   xs -->
<!--     .filter((x) => x % 2 === 0) -->
<!--     .map((x) => x * x) -->
<!--     .reduce((a, b) => a + b, 0); -->
<!---->
<!-- const pipeline = -->
<!--   <T, U, R>( -->
<!--     predicate: (x: T) => boolean, -->
<!--     transform: (x: T) => U, -->
<!--     reducer: (acc: R, value: U) => R, -->
<!--     initial: R -->
<!--   ) => -->
<!--   (xs: T[]): R => -->
<!--     xs -->
<!--       .filter(predicate) -->
<!--       .map(transform) -->
<!--       .reduce(reducer, initial); -->
<!---->
<!-- const processNumbers = pipeline( -->
<!--   (x: number) => x % 2 === 0, -->
<!--   (x: number) => x * x, -->
<!--   (acc: number, x: number) => acc + x, -->
<!--   0 -->
<!-- ); -->
<!---->
<!-- processNumbers([1, 2, 3, 4]); // 20 -->
<!-- ``` -->

---

👥 **Exercise 6:** Participants adapt it to:

- cube (^3) instead of square (^2)
- drop numbers < 10

---

# 6. Summary & Q&A

### 🎯 Key takeaways

- FP is just doing programming like math: pure, predictable, composable.
- Haskell gives us the purest view of FP.
- TypeScript lets us apply FP principles in real-world apps.
- TypeScript typing is a trade-off: too little loses safety, too much hurts readability — see `option.ts`

---

# 7. Optional Homework

1. Rewrite 5 small functions in TS to be pure.
2. Implement your own `compose` function:

```ts
const compose =
  <A, B, C>(f: (b: B) => C, g: (a: A) => B) =>
  (a: A) =>
    f(g(a));
```

1. Look up: What is a functor?

---
