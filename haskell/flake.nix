{
  description = "Dev shell with GHCi";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux"; # change to "aarch64-darwin" on mac M1/M2
      pkgs = import nixpkgs {
        inherit system;
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pkgs.ghc # brings ghci
          pkgs.cabal-install # optional but usually nice to have
        ];
      };
    };
}
