{ config, pkgs, lib, ... }:

{
  services.prometheus.exporters.node = {
    enable = true;
    listenAddress = "[::1]";
  };

  fluepke.monitoring.exporters.node-exporter = {};

  services.nginx.virtualHosts.${config.fluepke.deploy.fqdn} = let
    addr = config.services.prometheus.exporters.node.listenAddress;
    port = toString config.services.prometheus.exporters.node.port;
  in {
    locations."/node-exporter/metrics".proxyPass = "http://${addr}:${port}/metrics";
  };
}
