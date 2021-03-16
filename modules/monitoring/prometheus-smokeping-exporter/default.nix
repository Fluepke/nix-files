{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.fluepke.monitoring.prometheus-smokeping-exporter;
in {
  options = {
    fluepke.monitoring.prometheus-smokeping-exporter = {
      enable = mkEnableOption "Enable Prometheus style smokeping prober";
      listenAddress = mkOption {
        type = types.str;
        description = "Address and port to bind to";
        default = "[::1]:9374";
      };
      telemetryPath = mkOption {
        type = types.str;
        description = "Path under which to expose metrics";
        default = "/metrics";
      };
      hosts = mkOption {
        type = with types; listOf str;
        description = "List of hosts to ping";
        default = [ ];
      };
      pingInterval = mkOption {
        type = types.str;
        description = "Ping interval";
        default = "1s";
      };
    };
  };

  config = mkIf cfg.enable {
      environment.systemPackages = [ pkgs.prometheus-smokeping-exporter ];
      systemd.services.prometheus-smokeping-exporter =
        let
          hosts = concatStringsSep " " cfg.hosts;
        in {
          description = "Prometheus style smokeping prober";
          documentation = [ "https://github.com/SuperQ/smokeping_prober" ];
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];
          serviceConfig = {
            Restart = mkDefault "always";
            DynamicUser = "yes";
            ProtectSystem = "full";
            AmbientCapabilities = "CAP_NET_RAW";  # required for ICMP
          };
          script = ''
            ${pkgs.prometheus-smokeping-exporter}/bin/smokeping_prober \
              --web.listen-address="${cfg.listenAddress}" \
              --web.telemetry-path="${cfg.telemetryPath}" \
              --ping.interval=${cfg.pingInterval} \
              --privileged \
              ${hosts}
          '';
         };
  };
}
