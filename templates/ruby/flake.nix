{
  inputs.mine.url = "github:n-at-han-k/flake.nix";
  # follows: without it mine drags in a second nixpkgs closure.
  inputs.mine.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { mine, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = mine.lib.${system};
        gems = lib.buildGemset { name = "ratalada"; src = ./.; };
      in
      {
        devShells.default = lib.mkRubyShell {
          buildInputs = with pkgs; [
            gems
            gems.wrappedRuby
          ];
        };
      }
    );
}
