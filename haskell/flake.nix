{
  description = "Haskell development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      systems = nixpkgs.lib.platforms.unix;
      eachSystem =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f (
            import nixpkgs {
              inherit system;
              config = { };
              overlays = [ ];
            }
          )
        );
    in
    {
      # NOTE: Be advised that the specific versions of packages to be used for this project are listed in the FP FS
      # 2026 "Preparation" page on https://moodle.ost.ch/mod/page/view.php?id=714594. The versions of the packages
      # denoted below might differ from the recommendations in moodle.
      devShells = eachSystem (
        pkgs:
        let
          # The code below was adapted from
          # https://docs.haskellstack.org/en/stable/topics/nix_integration/#supporting-both-nix-and-non-nix-developers
          stack-isolated = pkgs.symlinkJoin {
            name = "stack";
            # NOTE: The input `stack` isn't explicitly pinned to any specific version.
            # WARN: Updating the flake lock (eg. by running `nix flake update`) might lead to inconsistent behavior.
            paths = [ pkgs.stack ];
            buildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/stack \
                --add-flags "\
                  --no-nix \
                  --system-ghc \
                  --no-install-ghc \
                "
            '';
          };
          devShell =
            allFeatures:
            pkgs.mkShell {
              buildInputs =
                # NOTE: The inputs `cabal-install` and `haskell-language-server` aren't explicitly pinned to any
                # specific version but are provided by `nixpkgs-unstable`, thus being chosen by the nixpkgs devs to be
                # fitting for the selected version of ghc below.
                # WARN: Changing the ghc version below might lead to inconsistent behavior.
                with pkgs.haskell.packages.ghc967;
                (
                  [
                    ghc
                    stack-isolated
                    cabal-install
                    haskell-language-server
                  ]
                  ++ (pkgs.lib.optionals allFeatures [
                    hlint
                    ghcid
                    ormolu
                    hoogle
                  ])
                );
            };

          full = devShell true;
          minimal = devShell false;
        in
        {
          inherit full minimal;
          default = full;
        }
      );
    };
}
