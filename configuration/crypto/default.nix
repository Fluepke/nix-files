{ config, lib, ... }:

with lib;

let
  setupInterface = name: i: let
    ips = i.ipv4.addresses ++ i.ipv6.addresses;
  in ''
    ip link set "${i.name}" up

    ${flip concatMapStrings ips (ip:
      let
        cidr = "${ip.address}/${toString ip.prefixLength}";
      in
      ''
        echo -n "adding address ${cidr}... "
        if out=$(ip addr add "${cidr}" dev "${i.name}" 2>&1); then
          echo "done"
        elif ! echo "$out" | grep "File exists" >/dev/null 2>&1; then
          echo "'ip addr add "${cidr}" dev "${i.name}"' failed: $out"
        fi
      ''
    )}
  '';

  setupGateway = gw: optionalString (gw != null) ''
    ip route add default via ${gw.address} dev ${gw.interface}
  '';
in {
  boot.initrd.availableKernelModules = [
    "r8169"
    "libphy"
    "realtek"
    "virtio-pci"
  ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
      postCommands = (
        concatStringsSep "\n" (
          mapAttrsToList setupInterface config.networking.interfaces
        )
      )
      + (setupGateway config.networking.defaultGateway6)
      + (setupGateway config.networking.defaultGateway)
      + ''
        echo 'cryptsetup-askpass' >> /root/.profile
      '';
  };
}
