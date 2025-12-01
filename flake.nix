{
  description = "Marp slides: build HTML via nix build, serve via nix run";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          let
            pkgs = import nixpkgs { inherit system; };

            # Prefer packaged marp-cli; fallback to nodePackages if available
            marpPkg =
              if pkgs ? marp-cli then
                pkgs.marp-cli
              else if pkgs ? nodePackages && pkgs.nodePackages ? "@marp-team/marp-cli" then
                pkgs.nodePackages."@marp-team/marp-cli"
              else
                pkgs.writeShellApplication {
                  name = "marp";
                  runtimeInputs = [ pkgs.nodejs ];
                  text = ''
                    # impure fallback (requires network)
                    exec ${pkgs.nodejs}/bin/npx @marp-team/marp-cli "$@"
                  '';
                };

            # Helper: choose markdown entry (SLIDES env or first *.md)
            # Helper: choose markdown entry (SLIDES env or first *.md)
            chooseSlides = ''
              set -eu
              SLIDES="''${SLIDES:-slides.md}"
              if [ ! -f "$SLIDES" ]; then
                shopt -s nullglob
                md_files=(./*.md)
                if [ "''${#md_files[@]}" -eq 0 ]; then
                  echo "No markdown file found (looked for $SLIDES or *.md)" >&2
                  exit 1
                fi
                SLIDES="''${md_files[0]}"
              fi
            '';
          in
          f {
            inherit
              pkgs
              marpPkg
              chooseSlides
              system
              ;
          }
        );
    in
    {
      # Package: builds a PDF slide deck at $out/slides.pdf
      packages = forAllSystems (
        {
          pkgs,
          marpPkg,
          chooseSlides,
          ...
        }:
        {
          slides =
            let
              # Headless chromium wrapper (unchanged)
              chromiumWrapped = pkgs.writeShellScriptBin "chromium-marp" ''
                exec ${pkgs.chromium}/bin/chromium \
                  --no-sandbox --disable-gpu --disable-dev-shm-usage "$@"
              '';

              # TeX Live with pdflatex and pdfjam (lightweight-ish)
              texlivePdfjam = pkgs.texlive.combine {
                inherit (pkgs.texlive)
                  scheme-small # includes LaTeX + pdflatex + many core packages
                  latex-bin
                  pdfjam
                  pdfpages # used by pdfjam
                  geometry # used by pdfjam
                  xcolor # commonly required
                  graphics # commonly required
                  tools
                  ; # commonly required
              };
            in
            pkgs.stdenvNoCC.mkDerivation {
              pname = "slides";
              version = "1.0";
              src = ./.;

              nativeBuildInputs = [
                marpPkg
                pkgs.chromium
                chromiumWrapped
                texlivePdfjam
                pkgs.fontconfig
                pkgs.dejavu_fonts
                pkgs.noto-fonts
                pkgs.noto-fonts-cjk-sans
                pkgs.noto-fonts-emoji
                pkgs.coreutils
                pkgs.findutils
              ];

              FONTCONFIG_FILE = pkgs.makeFontsConf {
                fontDirectories = [
                  pkgs.dejavu_fonts
                  pkgs.noto-fonts
                  pkgs.noto-fonts-cjk-sans
                  pkgs.noto-fonts-emoji
                ];
              };

              LANG = "C.UTF-8";
              dontConfigure = true;
              dontBuild = true;

              installPhase = ''
                set -eu
                ${chooseSlides}
                mkdir -p "$out"

                export HOME="$TMPDIR"
                export XDG_CACHE_HOME="$TMPDIR/.cache"

                base_pdf="$TMPDIR/slides.pdf"

                # 1) Render 1-up with Marp (explicit browser path)
                ${pkgs.lib.getExe marpPkg} "$SLIDES" \
                  --allow-local-files \
                  --browser-path "${chromiumWrapped}/bin/chromium-marp" \
                  -o "$base_pdf"

                    cp "$base_pdf" "$out/slides-1up.pdf"

                # 2-up and 4-up via pdfjam (from texlivePdfjam)
                "${texlivePdfjam}/bin/pdfjam" \
                  --paper a4paper --landscape --nup 2x1 --scale 0.95 \
                  "$base_pdf" --outfile "$out/slides-2up.pdf"

                "${texlivePdfjam}/bin/pdfjam" \
                  --paper a4paper --landscape --nup 2x2 --scale 0.95 \
                  "$base_pdf" --outfile "$out/slides-4up.pdf"              '';

              meta.description = "Marp slides as 1-up, 2-up, and 4-up PDFs (A4).";
            };

          default = self.packages.${pkgs.system}.slides;
        }
      );

      # App: run a live server so you can present / edit
      apps = forAllSystems (
        {
          pkgs,
          marpPkg,
          chooseSlides,
          ...
        }:
        {
          default =
            let
              serveScript = pkgs.writeShellApplication {
                name = "serve-slides";
                runtimeInputs = [
                  marpPkg
                  pkgs.coreutils
                ];
                text = ''
                  set -eu
                  ${chooseSlides}
                  export PORT="''${PORT:-3777}"

                  if [ -d "$SLIDES" ]; then
                    SERVE_DIR="$SLIDES"
                    PAGE=""
                  else
                    SERVE_DIR="$(dirname -- "$SLIDES")"
                    PAGE="/$(basename -- "$SLIDES")"
                  fi

                  echo "Serving $SERVE_DIR on http://localhost:$PORT$PAGE"
                  # Marp serves a directory; open the specific file via /<name>.md
                  exec ${pkgs.lib.getExe marpPkg} --server "$SERVE_DIR" 
                '';
              };
            in
            {
              type = "app";
              program = "${serveScript}/bin/serve-slides";
            };

          marp = {
            type = "app";
            program = pkgs.lib.getExe marpPkg;
          };
        }
      );

      # Dev shell with marp available
      devShells = forAllSystems (
        { pkgs, marpPkg, ... }:
        {
          default = pkgs.mkShell {
            packages = [
              marpPkg
              pkgs.nodejs
              pkgs.yarn
            ];
          };
        }
      );
    };
}
