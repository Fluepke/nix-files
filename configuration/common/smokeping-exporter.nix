{ config, pkgs, lib, ... }:

let
  inherit (import ../../lib/hosts.nix { inherit pkgs; }) hosts;
in {
  fluepke.monitoring = {
    exporters = [ "smokeping" ];
    prometheus-smokeping-exporter = {
      enable = true;
      hosts = lib.mapAttrsToList (
        name: host: host.config.fluepke.deploy.fqdn)
        hosts;
    };
  };
}
