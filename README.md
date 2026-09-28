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

## Without flakes

`lib.nix` is the source of truth; the flake only re-exports it per system. On
stable Nix:

```nix
{ pkgs ? import <nixpkgs> { } }:
let
  lib = import (fetchTarball "https://github.com/n-at-han-k/flake.nix/archive/main.tar.gz") { inherit pkgs; };
  gems = lib.buildGemset { name = "ratalada"; src = ./.; };
in
lib.mkRubyViteShell {
  buildInputs = [ gems gems.wrappedRuby ];
}
```

`overlays.default` stays flake-only on purpose: it exists to pin the packages to
this flake's nixpkgs, and a plain overlay could only hand back your own attrs.
