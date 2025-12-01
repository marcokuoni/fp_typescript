# in the directory with flake.nix

```bash
nix develop
ghci
```

## First Example

```haskell
ghci> add1 x = x + 1
ghci> double x= x * 2
ghci> f = add1 . double
ghci> f 3
7
:quit
```

## Second Example

`ghci ImmutabilityDemo.hs`
