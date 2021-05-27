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
    # ./wireguard.nix
  ];

  petabyte.network = {
    enable = true;
    localAS = 208135;
    magicNumber = 3;
    primaryIP = "2a0f:5381:cafe::1";
    primaryIP4 = "45.158.42.1";
    #extraConfig = lib.fileContents ./bird-extra.conf;
    #peers = import ./peers.nix { inherit config; };
    wireguard = {
      PublicKey = "+wEJZo9cnQ9jFvPz4S8XV5+unqwrNF3M8+d+GOQrA1E=";
    };
  };
  networking.hostName = "home";
  networking.domain = "fluep.ke";
}
