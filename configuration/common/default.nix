{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules
    ./users.nix
    ./shell.nix
    ./ssh.nix
    ./nginx.nix
    ./monitoring.nix
  ];

  # boot.kernelPackages = pkgs.linuxPackages_latest;
  security.sudo.wheelNeedsPassword = false;
  nix.trustedUsers = [ "@wheel" ];

  nixpkgs.config.packageOverrides = import ../../pkgs { inherit pkgs lib; };
  environment.systemPackages = with pkgs; [
    wget vim htop nload fd ripgrep exa bat dnsutils
    tmux curl jq git socat usbutils pciutils termite.terminfo
  ];

  time.timeZone = "Etc/UTC";

  programs.mtr.enable = true;
}
