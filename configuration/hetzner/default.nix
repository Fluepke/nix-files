{ lib, config, ... }:

{
  boot.loader.grub.device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0-0-0-0";
  boot.initrd.availableKernelModules = lib.optional config.boot.initrd.network.enable "virtio-pci";
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 2222;
      hostKeys = [ "/var/src/secrets/initrd/ed25519-hostkey" ];
      authorizedKeys = with lib;
        concatLists (mapAttrsToList (name: user:
          if elem "wheel" user.extraGroups then
            user.openssh.authorizedKeys.keys
          else
            [ ]) config.users.users);
    };
    postCommands = ''
      echo 'cryptsetup-askpass' >> /root/.profile
    '';
  };
}
