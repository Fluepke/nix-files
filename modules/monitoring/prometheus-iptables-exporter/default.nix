{ config, lib, pkgs, ...}:

with lib;

let
  cfg = config.fluepke.monitoring.prometheus-iptables-exporter;
in {
  options = {
    fluepke.monitoring.prometheus-iptables-exporter = {
      enable = mkEnableOption "Enable iptables prometheus exporter";
      listenAddress = mkOption {
        type = types.str;
        default = "[::1]:9455";
      };
    };
  };
  config = mkIf cfg.enable {
    fluepke.monitoring.exporters.iptables-exporter = {};

    systemd.services.prometheus-iptables-exporter = {
      description = "iptables prometheus exporter";
      documentation = [ "https://github.com/retailnext/iptables_exporter" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.iptables ];
      serviceConfig = {
        Restart = mkDefault "always";
        DynamicUser = "yes";
        ProtectSystem = "full";
        PrivateTmp = "true";
        CapabilityBoundingSet = "CAP_DAC_READ_SEARCH CAP_NET_ADMIN CAP_NET_RAW";
        AmbientCapabilities = "CAP_DAC_READ_SEARCH CAP_NET_ADMIN CAP_NET_RAW";
      };
      script = ''
        ${pkgs.prometheus-iptables-exporter}/bin/iptables_exporter \
          --web.listen-address="${cfg.listenAddress}"
      '';
    };

    services.nginx.virtualHosts.${config.fluepke.deploy.fqdn} = {
      locations."/iptables-exporter/metrics".proxyPass = "http://${cfg.listenAddress}/metrics";
    };
  };
}
