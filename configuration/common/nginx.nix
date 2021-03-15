{ config, ... }:

{
  users.users.nginx.extraGroups = [ "acme" ];
  services.nginx = {
    enable = true;
    statusPage = true;
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
