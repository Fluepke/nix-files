{ lib, ... }:

with lib;

{
  imports = [
    ./prometheus-vodafone-station-exporter
    ./prometheus-iptables-exporter
    ./prometheus-zyxel-exporter
  ];

  options = {
    fluepke.monitoring.exporters = mkOption {
      type = with types; listOf str;
    };
  };
}
