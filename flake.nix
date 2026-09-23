{
  description = "n-at-han-k's flake stuff from github.com";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.systems.url = "github:nix-systems/default";

  outputs = { self, nixpkgs, systems }:
    let
      names = [
        "ruby_3_4"
        "bundix"
        "libyaml"
        "openssl"
        "nodejs"
        "pnpm"
        "tmux"
        "overmind"
        "pkg-config"
      ];

      eachSystem = nixpkgs.lib.genAttrs (import systems);
      pick = pkgs: nixpkgs.lib.getAttrs names pkgs;
    in
    {
      packages = eachSystem (system: pick nixpkgs.legacyPackages.${system});

      # Takes the packages from THIS flake's nixpkgs, not the consumer's,
      # so every consumer resolves the same derivation hashes.
      overlays.default = final: prev:
        pick nixpkgs.legacyPackages.${prev.stdenv.hostPlatform.system};

      # Per-system: mine.lib.${system}.mkRubyShell { ... }
      lib = eachSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        rec {
          # Appends buildInputs/nativeBuildInputs/shellHook; anything else in
          # attrs replaces the base.
          mkShellMerge = base: attrs: base // attrs // {
            nativeBuildInputs = (base.nativeBuildInputs or [ ]) ++ (attrs.nativeBuildInputs or [ ]);
            buildInputs = (base.buildInputs or [ ]) ++ (attrs.buildInputs or [ ]);
            shellHook = (base.shellHook or "") + (attrs.shellHook or "");
          };

          buildGemset = { name, src, ruby ? pkgs.ruby_3_4 }:
            pkgs.bundlerEnv {
              inherit name ruby;
              gemfile = src + "/Gemfile";
              lockfile = src + "/Gemfile.lock";
              gemset = src + "/gemset.nix";
            };

          mkShell = attrs: pkgs.mkShell (mkShellMerge { } attrs);

          mkRubyShell = attrs: mkShell (mkShellMerge {
            nativeBuildInputs = [ pkgs.pkg-config ];
            buildInputs = with pkgs; [ bundix libyaml openssl overmind tmux ];
            shellHook = ''
              bundix -l
            '';
          } attrs);

          mkRubyViteShell = attrs: mkRubyShell (mkShellMerge
            {
              nativeBuildInputs = [ pkgs.pnpmConfigHook ];
              buildInputs = with pkgs; [ nodejs pnpm ];
              # pnpmConfigHook only runs as a build phase; devShells run none.
              shellHook = ''
                pnpm install
                git add -N .
                runHook postPatch
              '';
            }
            attrs);
        });
    };
}
