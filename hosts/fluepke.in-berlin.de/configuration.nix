# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./networking
      ../../configuration/common
    ];

  #fluepke.deploy.ssh.host = "fluepke.in-berlin.de";
  fluepke.deploy.ssh.host = "217.197.83.150";
  fluepke.deploy.ssh.port = 22;
  fluepke.deploy.groups = [ "fluepke" ];

  users.users.fluepke.hashedPassword = "$6$BuaLj76Tb0fm6.$ClZfAeJSnhUxliYChnok9YJ6AbvCnscW1BN.8FsWNWwvJBi9qEmkQYOcyN9OCi85IOeKaXBSq7WjEPEUE9D8M1";

  networking.hostName = "fluepke";
  networking.domain = "in-berlin.de";

  # Use the systemd-boot EFI boot loader.
  boot.loader.grub.device = "/dev/vda";

  # No connection tracking
  boot.blacklistedKernelModules = [
    "nf_conntrack"
    "nf_conntrack_helper"
  ];

  boot.kernelParams = [ "console=tty0" "console=ttyS0,115200n8" ];
  boot.loader.grub.extraConfig = "
    serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1
    terminal_input serial
    terminal_output serial
  ";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
