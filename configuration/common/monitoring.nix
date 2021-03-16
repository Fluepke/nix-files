{ config, pkgs, lib, ... }:

{
  imports = [
    ./node-exporter.nix
    ./smokeping-exporter.nix
  ];

  fluepke.monitoring.prometheus-iptables-exporter.enable = true;

  services.prometheus.exporters.node = {
    enable = true;
    listenAddress = "[::1]";
    enabledCollectors = [
      "ntp"
      "systemd"
    ];
  };
}
