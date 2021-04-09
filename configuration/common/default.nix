{ config, pkgs, lib, sources, ... }:

let
  sources = import ../../nix/sources.nix;
in
{
  imports = [
    ../../modules
    (sources.home-manager + "/nixos")
    ./acme.nix
    ./fail2ban.nix
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
    wget vim htop nload fd ripgrep exa bat dnsutils
    tmux curl jq git socat usbutils pciutils termite.terminfo
    iperf3 nmap bmon
    tcpdump telnet swaks netcat
    git hexyl yq zsh
  ];

  time.timeZone = "Etc/UTC";

  programs.mtr.enable = true;
}
