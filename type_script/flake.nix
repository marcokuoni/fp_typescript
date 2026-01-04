{
  description = "Dev shell with TypeScript tooling";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pkgs.nodejs_20
          pkgs.nodePackages.typescript
          pkgs.nodePackages.typescript-language-server
          pkgs.nodePackages.eslint
          pkgs.nodePackages.prettier
        ];

        shellHook = ''
          echo "TypeScript dev shell ready"
          echo "node $(node --version)"
          echo "tsc $(tsc --version)"
        '';
      };
    };
}
