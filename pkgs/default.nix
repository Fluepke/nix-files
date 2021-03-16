{ pkgs, ... }:

let
  callPackage = pkgs.lib.callPackageWith(pkgs // custom );
  custom = {
    prometheus-iptables-exporter = callPackage ./prometheus-iptables-exporter {};
    prometheus-smokeping-exporter = callPackage ./prometheus-smokeping-exporter {};
    prometheus-vodafone-station-exporter = callPackage ./prometheus-vodafone-station-exporter {};
    prometheus-zyxel-exporter = callPackage ./prometheus-zyxel-exporter {};
  };
in custom
