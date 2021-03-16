{ lib, ... }:

with lib;

{
  imports = [
    ./prometheus-iptables-exporter
    ./prometheus-smokeping-exporter
    ./prometheus-vodafone-station-exporter
    ./prometheus-zyxel-exporter
  ];

  options = {
    fluepke.monitoring.exporters = mkOption {
      type = with types; listOf str;
    };
  };
}
