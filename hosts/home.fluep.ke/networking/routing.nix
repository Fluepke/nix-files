{ ... }:

{
  #networking.nat = {
  #  enable = true;
  #  internalInterfaces = [ "enp2s0" ];
  #  externalInterface = "wan";
  #};
  petabyte.nftables.extraConfig = ''
    table ip nat {
      chain postrouting {
        type nat hook postrouting priority 100
        # masquerade private IP addresses
        iifname enp2s0 oifname wan masquerade
      }
    }
  '';
}
