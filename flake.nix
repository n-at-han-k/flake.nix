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

      # Takes the packages from THIS flake's nixpkgs, not the consumer's, so
      # every consumer resolves the same derivation hashes. That pin is the
      # whole point of this overlay, so it stays in flake.nix — a plain
      # overlay.nix could only ever hand back the consumer's own attrs.
      overlays.default = final: prev:
        pick nixpkgs.legacyPackages.${prev.stdenv.hostPlatform.system};

      # lib.nix holds the builders; this flake only re-exports them per system.
      # Per-system: mine.lib.${system}.mkRubyShell { ... }
      lib = eachSystem (system: import ./lib.nix {
        pkgs = nixpkgs.legacyPackages.${system};
      });
    };
}
