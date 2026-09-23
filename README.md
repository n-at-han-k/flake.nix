# flake.nix

## Usage

```nix
{
  inputs.mine.url = "github:n-at-han-k/flake.nix";

  outputs = { mine, ... }:
    let
      lib = mine.lib.x86_64-linux;
      gems = lib.buildGemset { name = "ratalada"; src = ./.; };
    in
    {
      devShells.x86_64-linux.default = lib.mkRubyViteShell {
        buildInputs = [ gems gems.wrappedRuby ];
      };
    };
}
```
