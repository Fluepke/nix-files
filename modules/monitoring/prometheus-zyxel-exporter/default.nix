{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.fluepke.monitoring.prometheus-zyxel-exporter;
in {
  options = {
    fluepke.monitoring.prometheus-zyxel-exporter = {
      enable = mkEnableOption "Enable prometheus-zyxel-exporter";
      listenAddress = mkOption {
        type = types.str;
        default = "[::]:9237";
      };
      user = mkOption {
        type = types.str;
        default = "prometheus-zyxel-exporter";
      };
      group = mkOption {
        type = types.str;
        default = "prometheus-zyxel-exporter";
      };
      zyxelHost = mkOption {
        type = types.str;
        default = "10.0.0.2";
      };
      zyxelPasswordFile = mkOption {
        type = types.str;
      };
    };
  };
  config = mkIf cfg.enable {
    fluepke.monitoring.exporters.zyxel-exporter = {};

    users.users.prometheus-zyxel-exporter = mkIf (cfg.user == "prometheus-zyxel-exporter") {
      group = "prometheus-zyxel-exporter";
      isSystemUser = true;
    };
    users.groups.prometheus-zyxel-exporter = mkIf (cfg.group == "prometheus-zyxel-exporter") {};

    systemd.services.prometheus-zyxel-exporter = {
      description = "Zyxel GS1200 Prometheus Exporter";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Restart = mkDefault "always";
        ProtectSystem = "full";
        PrivateTmp = "true";
        User = cfg.user;
        Group = cfg.group;
      };
      script = ''
        ${pkgs.prometheus-zyxel-exporter}/bin/prometheus-zyxel-exporter \
          -web.listen-address ${cfg.listenAddress} \
          -zyxel.host ${cfg.zyxelHost} \
          -zyxel.pass $(cat ${cfg.zyxelPasswordFile})
      '';
    };

    services.nginx.virtualHosts.${config.fluepke.deploy.fqdn} = {
      locations."/zyxel-exporter/metrics".proxyPass = "http://${cfg.listenAddress}/metrics";
    };
  };
}
