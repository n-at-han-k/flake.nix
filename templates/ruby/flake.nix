{
  inputs.mine.url = "github:n-at-han-k/flake.nix";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/unstable";
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
