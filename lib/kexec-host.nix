{ lib, pkgs, config, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/netboot/netboot-minimal.nix")
    ../configuration/common
  ];

  boot.loader.grub.enable = false;
  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
  networking.hostName = "kexec";
  networking.domain = "fluep.ke";

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
