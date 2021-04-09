{ lib, ... }:

with lib;

let exporterOpts = { ... }: {
  options.interval = mkOption {
    type = types.str;
    default = "10s";
  };
  options.timeout = mkOption {
    type = types.str;
    default = "10s";
  };
};
in {
  imports = [
    ./prometheus-f2b-exporter
    ./prometheus-ios-exporter
    ./prometheus-iperf3-exporter
    ./prometheus-iptables-exporter
    ./prometheus-smokeping-exporter
    ./prometheus-vodafone-station-exporter
    ./prometheus-zyxel-exporter
  ];

  options = {
    fluepke.monitoring.exporters = mkOption {
      type = with types; attrsOf (submodule exporterOpts);
    };
  };
}
