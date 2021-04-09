{ config, pkgs, lib, ... }:

{
  imports = [
    ./blackbox-exporter.nix
    ./ios-exporter.nix
    ./iperf3-exporter.nix
    ./node-exporter.nix
    ./smokeping-exporter.nix
    ./wireguard-exporter.nix
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
