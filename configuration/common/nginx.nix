{ config, ... }:

{
  users.users.nginx.extraGroups = [ "acme" ];
  users.users.nginx.isSystemUser = true;
  services.nginx = {
    enable = true;
    statusPage = true;
    virtualHosts.${config.fluepke.deploy.fqdn} = {
      enableACME = true;
      forceSSL = true;
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
