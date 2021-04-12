{ ... }:

{
  boot.kernel.sysctl = {
    "net.ipv6.conf.all.forwarding" = true;
    "net.ipv4.conf.all.forwarding" = true;
  };

  networking.nat = {
    enable = true;
    internalInterfaces = [ "enp2s0" ];
    externalInterface = "wan";
  };
}
