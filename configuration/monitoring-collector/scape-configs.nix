{ config, lib, hosts, ... }:

with lib;

let
  sampleLimit = 42000;
  exporters = unique (
    flatten (
      mapAttrsToList (
        name: host: builtins.attrNames host.config.fluepke.monitoring.exporters
      ) hosts
    )
  );
  removePort = [
    {
      source_labels = [ "__address__" ];
      target_label = "instance";
      regex = "^(.*):?\\d*";
      action = "replace";
    }
  ];
  rewriteToLocal = [
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
  blackboxModules = {
    ssh = 22;
    https = 443;
    disk-crypto = 2222;
    icmp = 80;
  };
  mkBlackboxJob = module: port: {
    job_name = "blackbox-${module}";
    scheme = "https";
    relabel_configs = rewriteToLocal;
    static_configs = [{
      targets = mapAttrsToList (
        name: host: host.config.fluepke.deploy.fqdn + ":" + toString port
      ) hosts;
    }];
    metrics_path = "blackbox-exporter/probe";
    sample_limit = sampleLimit;
    params = { module = [ module ]; };
  };
  mkHostsForExporter = exporterName: (
    filterAttrs (
      name: host: builtins.hasAttr exporterName host.config.fluepke.monitoring.exporters
      ) hosts
    );
  mkTargets = filteredHosts: mapAttrsToList (
    name: host: mkTarget host) filteredHosts;
    
  mkTarget = host: {
    targets = [ host.config.fluepke.deploy.fqdn ];
  };
  mkJob = exporterName: {
    job_name = exporterName;
    scheme = "https";
    relabel_configs = removePort;
    static_configs = mkTargets (mkHostsForExporter exporterName);
    metrics_path = "/${exporterName}/metrics";
    sample_limit = sampleLimit;
    scrape_interval = builtins.head (
      mapAttrsToList (
        name: host: host.config.fluepke.monitoring.exporters.${exporterName}.interval
      ) (mkHostsForExporter exporterName)
    );
    scrape_timeout = builtins.head (
      mapAttrsToList (
        name: host: host.config.fluepke.monitoring.exporters.${exporterName}.timeout
      ) (mkHostsForExporter exporterName)
    );
  };

  iperf3Job = {
    job_name = "iperf3";
    scheme = "https";
    relabel_configs = rewriteToLocal;
    static_configs = [{
      labels = {
        source = config.fluepke.deploy.fqdn;
      };
      targets = mapAttrsToList (
        name: host: host.config.fluepke.deploy.fqdn
        ) (
          filterAttrs (
            name: host: host.config.services.iperf3.enable &&
              host.config.fluepke.deploy.fqdn != config.fluepke.deploy.fqdn
            ) hosts
          );
        }
      ];
      metrics_path = "/iperf3-exporter/probe";
      sample_limit = sampleLimit;
      scrape_interval = "120s";
      scrape_timeout = "30s";
      params = { period = [ "5s" ]; };
  };

in (forEach exporters mkJob) ++ (mapAttrsToList mkBlackboxJob blackboxModules) ++
 (if config.fluepke.monitoring.prometheus-iperf3-exporter.enable then [ iperf3Job ] else [])
