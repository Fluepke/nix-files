# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/05501755-2a2d-49dd-b7d9-7f4ef75310ae";
      fsType = "xfs";
    };

  boot.initrd.luks.devices."crypto".device = "/dev/disk/by-uuid/6139bc90-1fc9-48d4-85ad-c2d3b02c3b08";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/F9B8-EC25";
      fsType = "vfat";
    };

  swapDevices = [ ];

}
