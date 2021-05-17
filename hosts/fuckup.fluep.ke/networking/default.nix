{ config, lib, ... }:

{
  networking.useDHCP = false;
  networking.interfaces = {
    enp1s0 = { # salat-ix
      useDHCP = false;
      ipv4.addresses = [{
        address = "10.76.237.1"; prefixLength = 24;
      }];
      ipv6.addresses = [{
        address = "fd42:acab::20:8135:1"; prefixLength = 64;
      }];
    };
    enp7s0.useDHCP = true; # br-pbb - mgmt access in case of disaster
    enp8s0 = { # br-fluepke
      ipv4.addresses = [{
        address = "45.158.41.1"; prefixLength = 24;
      }];
      ipv6.addresses = [{
        address = "2a0f:5381::1"; prefixLength = 64;
      }];
    };
  };

  boot.kernel.sysctl."net.ipv6.conf.enp1s0.accept_ra" = false;
  boot.kernel.sysctl."net.ipv6.conf.enp8s0.accept_ra" = false;

  networking.firewall.checkReversePath = false;

  networking.firewall.allowedTCPPorts = [ 179 ];

  # services.bird2.enable = true;
  # services.bird2.config = lib.fileContents ./bird.conf;
  fluepke.network = {
    enable = true;
    #primaryIp = "2a0f:5381:1::1";
    #primaryIp4 = "45.158.";
    locationPrefix = "2a0f:5381:1::/48";
    locationTunnelPrefix = "2a0f:5382:1::/48";
  };
 
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = true;
  boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = true;
}
