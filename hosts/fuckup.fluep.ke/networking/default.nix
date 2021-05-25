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

  systemd.network.networks = {
    "40-enp1s0".networkConfig.IPv6AcceptRA = false;
    "40-enp8s0".networkConfig.IPv6AcceptRA = false;
  };
  
  networking.firewall.checkReversePath = false;

  networking.firewall.allowedTCPPorts = [ 179 ];

  services.bird2.enable = true;
  services.bird2.config = lib.fileContents ./bird.conf;
  petabyte.network = {
    enable = true;
    magicNumber = 1;
    primaryIP = "2a0f:5381:1312::1";
    primaryIP4 = "45.158.43.1";
    wireguard = {
      PublicKey = "GXcEdPIC/0YmW/RBGRN3FYGJyXMJN+64OhGgJNw2WFo=";
      Endpoint = "2a0f:5382:1312::1";
      hasLocationTunnelPrefix = true;
      Endpoint4 = "45.158.41.1";
      hasLocationTunnelPrefix4 = true;
    };
  };
}
