{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.fluepke.monitoring.prometheus-tc4400-exporter;
in {
  options = {
    fluepke.monitoring.prometheus-tc4400-exporter = {
      enable = mkEnableOption "Enable prometheus tc4400 exporter";
      listenAddress = mkOption {
        type = types.str;
        default = "[::]:9623";
      };
      clientScrapeUri = mkOption {
        type = types.str;
        default = "http://admin:bEn2o%23US9s@192.168.0.1";
      };
    };
  };
  config = mkIf cfg.enable {
    fluepke.monitoring.exporters.tc4400-exporter = {
      interval = "15s";
      timeout = "15s";
    };

    systemd.services.prometheus-tc4400-exporter = {
      description = "tc4400-exporter";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Restart = mkDefault "always";
        ProtectSystem = "full";
        PrivateTmp = "true";
        DynamicUser = "true";
      };
      script = ''
        ${pkgs.prometheus-tc4400-exporter}/bin/tc4400_exporter \
          --web.listen-address="${cfg.listenAddress}" \
          --client.scrape-uri="${cfg.clientScrapeUri}"
      '';
    };

    services.nginx.virtualHosts.${config.fluepke.deploy.fqdn} = {
      locations."/tc4400-exporter/metrics".proxyPass = "http://${cfg.listenAddress}/metrics";
    };
  };
}
