{
  description = "n-at-han-k's flake stuff from github.com";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.systems.url = "github:nix-systems/default";

  outputs = { self, nixpkgs, systems }:
    let
      # Safe to put in an overlay: nothing in stdenv references them.
      leafNames = [
        "ruby_3_4"
        "bundix"
        "nodejs"
        "pnpm"
        "tmux"
        "overmind"
      ];

      # NOT safe to overlay. stdenv splices pkg-config, and openssl/libyaml sit
      # deep in its closure, so overriding any of them in the fixpoint rebuilds
      # stdenv and all of nixpkgs from source. Exported as packages so a
      # consumer can take the pinned build explicitly, where it only affects
      # what they asked for.
      stdenvNames = [ "libyaml" "openssl" "pkg-config" ];

      names = leafNames ++ stdenvNames;

      eachSystem = nixpkgs.lib.genAttrs (import systems);
      pick = pkgs: nixpkgs.lib.getAttrs names pkgs;
    in
    {
      packages = eachSystem (system: pick nixpkgs.legacyPackages.${system});

      # Takes the packages from THIS flake's nixpkgs, not the consumer's, so
      # every consumer resolves the same derivation hashes. That pin is the
      # whole point of this overlay, so it stays in flake.nix — a plain
      # overlay.nix could only ever hand back the consumer's own attrs.
      # leafNames only: see stdenvNames above.
      overlays.default = final: prev:
        nixpkgs.lib.getAttrs leafNames
          nixpkgs.legacyPackages.${prev.stdenv.hostPlatform.system};

      # lib.nix holds the builders; this flake only re-exports them per system.
      # Per-system: mine.lib.${system}.mkRubyShell { ... }
      lib = eachSystem (system: import ./lib.nix {
        pkgs = nixpkgs.legacyPackages.${system};
      });
    };
}
