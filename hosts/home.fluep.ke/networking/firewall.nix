{ config, ... }:

{
  #  1500 (mtu)
  #
  #  20 (IPv4)
  #  8 (UDP)
  #  32 (WireGuard)
  #  20 (IPv4)
  #  20 (TCP)
  #  __
  #
  #  1400
  networking.firewall.extraCommands = ''
    iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1400
    ip6tables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1380
  '';
}
