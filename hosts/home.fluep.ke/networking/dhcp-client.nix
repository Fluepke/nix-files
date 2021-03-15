{ config, ... }:

{
  networking.dhcpcd.extraConfig = ''
    noipv6rs
    waitip 6
    # Uncomment this line if you are running dhcpcd for IPv6 only.
    #ipv6only

    # use the interface connected to WAN
    interface enp1s0
      iaid 1
      ipv6rs
      ia_na 1
      ia_pd 1 enp2s0
  '';
  networking.firewall.extraCommands = ''
    iptables -A INPUT -p udp --dport dhcpv6-client -j ACCEPT
  '';
}
