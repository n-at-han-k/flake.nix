{
  inputs.mine.url = "github:n-at-han-k/flake.nix";

  outputs = { mine, ... }:
    let
      lib = mine.lib.x86_64-linux;
      gems = lib.buildGemset { name = "vagrant"; src = ./.; };
    in
    {
      devShells.x86_64-linux.default = lib.mkRubyShell {
        buildInputs = [
          gems
          gems.wrappedRuby
        ];
      };
    };
}
