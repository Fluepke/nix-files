{ ... }:

{
  imports = [
    ./vlans.nix
    ./interfaces.nix
    ./routing.nix
    ./firewall.nix
    ./dhcp-client.nix
    ./dhcp-server.nix
    ./radvd.nix
    ./wireguard.nix
  ];

  networking.hostName = "home";
  networking.domain = "fluep.ke";
}
