{ config, pkgs, lib, ...}:

{
  config = lib.mkIf (config.networking.wg-quick.interfaces != {}) {
    fluepke.monitoring.exporters.wireguard-exporter = {};

    services.prometheus.exporters.wireguard = {
      enable = true;
      singleSubnetPerField = true;
      withRemoteIp = true;
      listenAddress = "127.0.0.1";
      extraFlags =[ "-a" ];
    };

    services.nginx.virtualHosts.${config.fluepke.deploy.fqdn} = {
      locations."/wireguard-exporter/metrics".proxyPass = let
        addr = config.services.prometheus.exporters.wireguard.listenAddress;
        port = toString config.services.prometheus.exporters.wireguard.port;
      in "http://${addr}:${port}/metrics";
    };
  };
}
