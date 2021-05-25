{ lib, ... }:

{
  networking.useDHCP = false;
  networking.interfaces.ens2.ipv4.addresses = [{
    address = "217.197.83.150"; prefixLength = 26;
  }];
  networking.interfaces.ens2.ipv6.addresses = [{
    address = "2001:67c:1400:20b0::1"; prefixLength = 64;
  }];

  systemd.network.networks."40-ens2" = {
    gateway = [ "217.197.83.129" "fe80::1" ];
    networkConfig.IPv6AcceptRA = false;
  };

  # tunnel ips
  networking.interfaces.lo.ipv4.addresses = [{
    address = "45.158.40.1"; prefixLength = 32;
  }];
  networking.interfaces.lo.ipv6.addresses = [{
    address = "2a0f:5382:acab::1"; prefixLength = 128;
  }];

  services.bird2.enable = true;
  services.bird2.config = lib.fileContents ./bird.conf;
  petabyte.network = {
    enable = true;
    magicNumber = 2;
    primaryIP = "2a0f:5381:acab::1";
    primaryIP4 = "45.158.43.2";
    wireguard = {
      PublicKey = "d4dwU5KFMgcesGT/UN6TWpYJk/MhKYQwGis5Gw67qTU=";
      Endpoint = "2001:67c:1400:20b0::1";
      hasLocationTunnelPrefix = false;
      Endpoint4 = "217.197.83.150";
      hasLocationTunnelPrefix4 = false;
      #Endpoint = "2a0f:5382:acab::1";
      #hasLocationTunnelPrefix = true;
      #Endpoint4 = "45.158.40.1";
      #hasLocationTunnelPrefix4 = true;
    };
  };
  #petabyte.network.
}
