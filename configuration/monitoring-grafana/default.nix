{ config, lib, pkgs, ... }:

{
  fluepke.monitoring.exporters.grafana = {};

  systemd.services.grafana-plugins = {
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = "true";
    partOf = [ "grafana.service" ];
    wantedBy = [ "multi-user.target" ];
    script = let
      plugins = [ "grafana-clock-panel" "grafana-piechart-panel" "vonage-status-panel"
                  "grafana-polystat-panel" "snuids-trafficlights-panel" "grafana-worldmap-panel" ];
    in lib.concatStringsSep "\n" (lib.forEach plugins (
      plugin: "${pkgs.grafana}/bin/grafana-cli plugins install ${plugin}" )
    );
  };

  systemd.services.grafana.after = [ "grafana-plugins.service" ];

  services.grafana = {
    enable = true;
    addr = "127.0.0.1";
    extraOptions.SERVER_SERVE_FROM_SUB_PATH = "true";
    domain = config.fluepke.deploy.fqdn;
    rootUrl = "https://${config.fluepke.deploy.fqdn}/grafana";
    provision = {
      enable = true;
      dashboards = [{
        disableDeletion = true;
        options.path = ./dashboards;
      }];
      datasources = [{
        type = "prometheus";
        name = "prometheus";
        url = "https://${config.fluepke.deploy.fqdn}/prometheus";
        isDefault = true;
        editable = false;
      }];
    };
    auth.anonymous.enable = true;
  };

  services.nginx.virtualHosts.${config.fluepke.deploy.fqdn} = {
    locations."/grafana".proxyPass = "http://${config.services.grafana.addr}:${toString config.services.grafana.port}/grafana";
  };
}
