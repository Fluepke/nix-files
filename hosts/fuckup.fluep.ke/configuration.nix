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

  fluepke.deploy.ssh.host = "195.39.247.162";
  fluepke.deploy.ssh.port = 22;
  fluepke.deploy.groups = [ "fuckup" ];

  users.users.fluepke.hashedPassword = "$6$DdepFACR$hynhaiTEMtUKQRg4QZ07mm9ZawpmOuNmUfNv06iWgIb2ubBnyAYkujwX7kAZ8uVNojBVCIsp5rr6b1b5zZ72a1";

  networking.hostName = "fuckup";
  networking.domain = "fluep.ke";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;

  # No connection tracking
  boot.blacklistedKernelModules = [
    "nf_conntrack"
    "nf_conntrack_helper"
  ];

  boot.kernelParams = [ "console=tty0" "console=ttyS0,115200n8" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
