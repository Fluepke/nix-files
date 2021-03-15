{ pkgs, ... }:

let
  callPackage = pkgs.lib.callPackageWith(pkgs // custom );
  custom = {
    prometheus-vodafone-station-exporter = callPackage ./prometheus-vodafone-station-exporter {};
    prometheus-iptables-exporter = callPackage ./prometheus-iptables-exporter {};
    prometheus-zyxel-exporter = callPackage ./prometheus-zyxel-exporter {};
  };
in custom
