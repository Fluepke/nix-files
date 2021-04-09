{ config, ... }:

{
#  fluepke.secrets.ios-exporter = {
#    source-path = "${../../secrets/all/ios-exporter.gpg}";
#    owner = config.fluepke.monitoring.prometheus-ios-exporter.user;
#  };
#
#  fluepke.monitoring.prometheus-ios-exporter = {
#    enable = true;
#    apiSecretFile = config.fluepke.secrets.ios-exporter.path;
#  };
}
