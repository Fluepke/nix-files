{ lib, ... }:

{
  fluepke.monitoring.prometheus-iperf3-exporter = {
    enable = lib.mkDefault true;
    iperf3OmitTime = "10s";
  };
}
