{ config, lib, pkgs, ...}:

with lib;

let
  cfg = config.fluepke.monitoring.prometheus-ios-exporter;
in {
  options = {
    fluepke.monitoring.prometheus-ios-exporter = {
      enable = mkEnableOption "Enable ios prometheus exporter";
      user = mkOption {
        type = types.str;
        default = "prometheus-ios-exporter";
      };
      group = mkOption {
        type = types.str;
        default = "prometheus-ios-exporter";
      };
      listenAddress = mkOption {
        type = types.str;
        default = "[::1]:9474";
      };
      apiSecretFile = mkOption {
        type = types.str;
      };
    };
  };
  config = mkIf cfg.enable {
    fluepke.monitoring.exporters.ios-exporter = {};

    users.users.prometheus-ios-exporter = mkIf (cfg.user == "prometheus-ios-exporter") {
      isSystemUser = true;
      group = "prometheus-ios-exporter";
    };
    users.groups.prometheus-ios-exporter = mkIf (cfg.group == "prometheus-ios-exporter") {};

    systemd.services.prometheus-ios-exporter = {
      description = "ios prometheus exporter";
      documentation = [ "https://github.com/fluepke/prometheus-ios-exporter" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Restart = mkDefault "always";
        DynamicUser = "yes";
        ProtectSystem = "full";
        PrivateTmp = "true";
      };
      script = ''
        ${pkgs.prometheus-ios-exporter}/bin/prometheus-ios-exporter \
          --web.listenAddress='${cfg.listenAddress}' \
          --api.secret="$(cat '${cfg.apiSecretFile}')"
      '';
    };

    services.nginx.virtualHosts.${config.fluepke.deploy.fqdn} = {
      locations."/ios-exporter".proxyPass = "http://${cfg.listenAddress}";
    };
  };
}
