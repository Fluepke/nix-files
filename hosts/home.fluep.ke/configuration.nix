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
      ../../configuration/crypto
    ];

  fluepke.deploy.ssh.host = "45.158.40.1";
  fluepke.deploy.ssh.port = 22;

  fluepke.secrets.zyxel-switch = {
    owner = config.fluepke.monitoring.prometheus-zyxel-exporter.user;
  };
  fluepke.monitoring.prometheus-zyxel-exporter = {
    enable = true;
    zyxelPasswordFile = config.fluepke.secrets.zyxel-switch.path;
  };

  fluepke.secrets.vodafone-station-password = {
    owner = config.fluepke.monitoring.prometheus-vodafone-station-exporter.user;
  };
  fluepke.monitoring.prometheus-vodafone-station-exporter = {
    enable = true;
    vodafoneStationPasswordFile = config.fluepke.secrets.vodafone-station-password.path;
  };

  networking.hostName = "home";
  networking.domain = "fluep.ke";

  # Use the systemd-boot EFI boot loader.
  boot.loader.grub.device = "/dev/nvme0n1";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.03"; # Did you read the comment?
}
