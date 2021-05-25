{ config, pkgs, lib, sources, ... }:

let
  sources = import ../../nix/sources.nix;
in
{
  imports = [
    ../../modules
    (sources.home-manager + "/nixos")
    ./acme.nix
    # ./fail2ban.nix
    ./iperf3.nix
    ./users.nix
    ./shell.nix
    ./ssh.nix
    ./nginx.nix
    ./monitoring.nix
  ];

  nixpkgs.config.allowUnfree = true;
  home-manager.useGlobalPkgs = true;

  # boot.kernelPackages = pkgs.linuxPackages_latest;
  security.sudo.wheelNeedsPassword = false;
  nix.trustedUsers = [ "@wheel" ];

  nixpkgs.config.packageOverrides = import ../../pkgs { inherit pkgs lib; };
  environment.systemPackages = with pkgs; [
    wget pv htop nload fd ripgrep exa bat dnsutils
    tmux curl jq git socat usbutils pciutils
    iperf3 nmap bmon net-snmp vim
    tcpdump telnet swaks netcat
    git hexyl yq zsh psmisc vgo2nix go
    wireguard-tools
  ];

  time.timeZone = "Etc/UTC";

  networking = {
    useDHCP = false;
    useNetworkd = true;
    nameservers = [ "2620:fe::fe" "2620:fe::fe:9" "9.9.9.9" "149.112.112.112" ];
  };
  services.resolved.enable = false;

  environment.etc."resolv.conf" = lib.mkForce {
    text = lib.concatMapStringsSep "\n" (x: "nameserver ${x}") config.networking.nameservers;
  };

  programs.mtr.enable = true;
}
