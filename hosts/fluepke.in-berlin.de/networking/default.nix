{ ... }:

{
  networking.useDHCP = false;
  boot.kernel.sysctl."net.ipv6.conf.ens2.accept_ra" = false;
  networking.interfaces.ens2.ipv4.addresses = [{
    address = "217.197.83.150"; prefixLength = 26;
  }];
  networking.interfaces.ens2.ipv6.addresses = [{
    address = "2001:67c:1400:20b0::1"; prefixLength = 64;
  }];
  networking.defaultGateway = {
    address = "217.197.83.129";
    interface = "ens2";
  };
  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "ens2";
  };
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "9.9.9.9"
    "2001:4860:4860::8888"
    "2001:4860:4860::8844"
  ];
}
