# The shell builders. This file is the source of truth; flake.nix re-exports it
# per system. It takes only `pkgs`, so stable (non-flake) Nix can use it:
#
#   (import ./lib.nix { pkgs = import <nixpkgs> { }; }).mkRubyShell { }
{ pkgs }:
rec {
  # Appends buildInputs/nativeBuildInputs/shellHook; anything else in attrs
  # replaces the base.
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
}
