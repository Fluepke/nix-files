{ config, lib, pkgs, ... }:

with lib;

let
  inherit (import ../../lib/hosts.nix { inherit pkgs; }) hosts;
in {
  fluepke.monitoring.exporters.prometheus = {};

  services.prometheus = {
    enable = true;
    listenAddress = "[::1]";
    extraFlags = [
      "--storage.tsdb.max-block-duration=2h"
      "--storage.tsdb.min-block-duration=2h"
      "--web.page-title=\"${config.fluepke.deploy.fqdn}\""
    ];
    globalConfig = {
      scrape_interval = "10s";
      scrape_timeout = "10s";
      evaluation_interval = "30s";
    };
    scrapeConfigs = import ./scape-configs.nix { inherit config lib hosts; };
    webExternalUrl = "https://${config.fluepke.deploy.fqdn}/prometheus";
  };

  services.nginx.virtualHosts.${config.fluepke.deploy.fqdn} = let
    addr = config.services.prometheus.listenAddress;
    port = toString config.services.prometheus.port;
  in {
    locations."/prometheus".proxyPass = "http://${addr}:${port}";
  };
}
