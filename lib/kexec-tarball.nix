{ pkgs }:

with pkgs.lib;

let
  evalConfig = import (pkgs.path + "/nixos/lib/eval-config.nix");

  hosts = import ../configuration/hosts;
  nixosHosts = filterAttrs (name: host: host ? ssh) hosts;

  nixos = import (pkgs.path + "/nixos") {
    configuration = import ./kexec-host.nix;
  };
in
  nixos.config.system.build.kexec_tarball
