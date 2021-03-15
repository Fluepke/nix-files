{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.fluepke.monitoring.prometheus-vodafone-station-exporter;
in {
  options = {
    fluepke.monitoring.prometheus-vodafone-station-exporter= {
      enable = mkEnableOption "Enable prometheus-vodafone-station-exporter";
      listenAddress = mkOption {
        type = types.str;
        default = "[::]:9420";
      };
      user = mkOption {
        type = types.str;
        default = "vodafone-station-exporter";
      };
      group = mkOption {
        type = types.str;
        default = "vodafone-station-exporter";
      };
      vodafoneStationPasswordFile = mkOption {
        type = types.str;
      };
      vodafoneStationUrl = mkOption {
        type = types.str;
        default = "http://192.168.0.1";
      };
    };
  };
  config = mkIf cfg.enable {
    fluepke.monitoring.exporters = [ "vodafone-station-exporter" ];

    users.users.prometheus-vodafone-station-exporter = mkIf (cfg.user == "prometheus-vodafone-station-exporter") {
      group = "prometheus-vodafone-station-exporter";
      isSystemUser = true;
    };
    users.groups.prometheus-vodafone-station-exporter = mkIf (cfg.group == "prometheus-vodafone-station-exporter") {};

    systemd.services.prometheus-vodafone-station-exporter = {
      description = "Vodafone Station (CGA4233DE) Prometheus Exporter";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Restart = mkDefault "always";
        ProtectSystem = "full";
        PrivateTmp = "true";
        User = cfg.user;
        Group = cfg.group;
      };
      script = ''
        ${pkgs.prometheus-vodafone-station-exporter}/bin/prometheus-vodafone-station-exporter \
          -web.listen-address ${cfg.listenAddress} \
          -vodafone.station-url ${cfg.vodafoneStationUrl} \
          -vodafone.station-password $(cat ${cfg.vodafoneStationPasswordFile})
      '';
    };

    services.nginx.virtualHosts.${config.fluepke.deploy.fqdn} = {
      locations."/vodafone-station-exporter/metrics".proxyPass = "http://${cfg.listenAddress}/metrics";
    };
  };
}
