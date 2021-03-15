{ ... }:

{
  boot.kernel.sysctl = {
    "net.ipv6.conf.all.forwarding" = true;
    "net.ipv4.conf.all.forwarding" = true;
  };

  networking.nat = {
    enable = true;
    internalIPs = [
      "10.0.0.0/24"
    ];
    externalInterface = "wan";
  };
}
