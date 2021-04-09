{ config, pkgs, lib, ...}:

with lib;

let
  cfg = config.fluepke.monitoring.prometheus-f2b-exporter;
in {
  options = {
    fluepke.monitoring.prometheus-f2b-exporter = {
      enable = mkEnableOption "Enable the fail2ban prometheus exporter";
      port = mkOption {
        type = types.int;
        default = 9247;
      };
      database = mkOption {
        type = types.str;
        default = "/var/lib/fail2ban/fail2ban.sqlite3";
      };
    };
  };
  config = mkIf cfg.enable {
    fluepke.monitoring.exporters.fail2ban-exporter = {};

    systemd.services.prometheus-f2b-exporter = {
      description = "Fail2ban prometheus exporter";
      documentation = [ "https://github.com/glvr182/f2b-exporter" ];
      wantedBy = [ "multi-user.target" ];
      after = [ "fail2ban.service" ];
      partOf = [ "fail2ban.service" ];
      script = ''
        ${pkgs.prometheus-f2b-exporter}/bin/f2b-exporter \
          --database ${cfg.database} \
          --port ${toString cfg.port}
      '';
    };
    services.nginx.virtualHosts.${config.fluepke.deploy.fqdn} = {
      locations."/fail2ban-exporter/metrics".proxyPass = "http://localhost:${toString cfg.port}/metrics";
    };
  };
}
