{ lib, pkgs, config, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/netboot/netboot-minimal.nix")
    #../configuration/common
  ];

  boot.loader.grub.enable = false;
  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
  networking.hostName = "kexec";
  networking.domain = "fluep.ke";

  users.users.fluepke = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "Mcr6kMGJxPLAzjPVlxUs";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIFPW/LUTmJn5Ip8x5HjrjENjCh+u9aA60uGzLpNsBag cardno:000611180084"
    ];
  };
  nix.trustedUsers = [ "@wheel" ];
  security.sudo.wheelNeedsPassword = false;

  networking.useDHCP = false;
  boot.kernel.sysctl."net.ipv6.conf.ens2.accept_ra" = false;
  networking.interfaces.ens2.ipv4.addresses = [{
    address = "217.197.83.150"; prefixLength = 26;
  }];
  networking.interfaces.ens2.ipv6.addresses = [{
    address = "2001:67c:1400:20b0::1"; prefixLength = 64;
  }];
  networking.defaultGateway = {
    address = "217.197.83.129";
    interface = "ens2";
  };
  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "ens2";
  };
  boot.kernelParams = [ "console=tty0" "console=ttyS0,115200n8" ];
  boot.loader.grub.extraConfig = "
    serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1
    terminal_input serial
    terminal_output serial
  ";

  services.nginx.enable = lib.mkForce false;
  security.acme.certs = lib.mkForce {};

  system.build = rec {
    image = pkgs.runCommand "image" { buildInputs = [ pkgs.nukeReferences ]; } ''
      mkdir $out
      cp ${config.system.build.kernel}/bzImage $out/kernel
      cp ${config.system.build.netbootRamdisk}/initrd $out/initrd
      echo "init=${builtins.unsafeDiscardStringContext config.system.build.toplevel}/init ${toString config.boot.kernelParams}" > $out/cmdline
      nuke-refs $out/kernel
    '';
    kexec_script = pkgs.writeTextFile {
      executable = true;
      name = "kexec-nixos";
      text = ''
        #!${pkgs.stdenv.shell}
        export PATH=${pkgs.kexectools}/bin:${pkgs.cpio}/bin:$PATH
        set -xe
        kexec -l ${image}/kernel --initrd=${image}/initrd --append="init=${builtins.unsafeDiscardStringContext config.system.build.toplevel}/init ${toString config.boot.kernelParams}"
        sync
        echo "executing kernel, filesystems will be improperly umounted"
        kexec -e
      '';
    };
  };
  system.build.kexec_tarball = pkgs.callPackage (pkgs.path + "/nixos/lib/make-system-tarball.nix") {
    storeContents = [
      { object = config.system.build.kexec_script; symlink = "/kexec_nixos"; }
    ];
    contents = [];
  };
}
