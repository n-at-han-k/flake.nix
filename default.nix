# Stable-Nix entry point: the shell builders, without flakes.
#
#   (import (fetchTarball "https://github.com/n-at-han-k/flake.nix/archive/main.tar.gz") { }).mkRubyViteShell { }
{ pkgs ? import <nixpkgs> { } }:
import ./lib.nix { inherit pkgs; }
