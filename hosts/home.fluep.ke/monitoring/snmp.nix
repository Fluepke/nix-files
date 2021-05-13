{ config, ... }:

{
  services.prometheus.exporters.snmp = {
    enable = true;
    listenAddress = "[::1]";
    configurationPath = "${./snmp.yml}";
  };

  fluepke.monitoring.exporters.snmp-exporter = {};

  services.nginx.virtualHosts.${config.fluepke.deploy.fqdn} = let
    addr = config.services.prometheus.exporters.snmp.listenAddress;
    port = toString config.services.prometheus.exporters.snmp.port;
  in {
    locations."/snmp-exporter/metrics".proxyPass = "http://${addr}:${port}/metrics";
    locations."/snmp-exporter/snmp".proxyPass = "http://${addr}:${port}/snmp";
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "modem";
      scheme = "https";
      scrape_interval = "1s";
      relabel_configs = [
        {
          source_labels = [ "__address__" ];
          target_label = "__param_target";
        }
        {
          source_labels = [ "__param_target" ];
          target_label = "instance";
        }
        {
          replacement = config.fluepke.deploy.fqdn;
          target_label = "__address__";
        }
      ];
      metrics_path = "/snmp-exporter/snmp";
      static_configs = [
        {
          targets = [ "modem.intern.wifi.fluep.ke" ];
        }
      ];
      params = { module = [ "if_mib" ]; };
    }
  ];

  networking.extraHosts = "192.168.0.1	modem.intern.wifi.fluep.ke";
}
