#!/usr/bin/env bash
export GC_DONT_GC=1
nix build -f https://github.com/kloenk/nixos-nix/archive/842331f0c33c348c268f751dcff5269b0cf2fe85.tar.gz packages.x86_64-linux.nix --out-link ~/.nix-unstable
~/.nix-unstable/bin/nix --experimental-features nix-command --log-format multiline build -f . $@
