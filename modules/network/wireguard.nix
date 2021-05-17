{ lib, config, groups, ... }:

with lib;

let
  cfg = config.fluepke.network;

  mkWireguard = ipv4: name: host:
    let
      ifname = if ipv4 then "wg4-${name}" else "wg6-${name}";
      hostCfg = host.config.fluepke.network;
      port = (if ipv4 then 52820 else 51820) + hostCfg.magicNumber + cfg.magicNumber;
    in nameValuePair ifname {
      listenPort = port;
      ips = [
        "fe80::${toString cfg.magicNumber}/64"
        "169.254.${toString (hostCfg.magicNumber + cfg.magicNumber)}.${toString cfg.magicNumber}/24"
      ];
      privateKeyFile = config.fluepke.secrets.wireguard.path;
      allowedIPsAsRoutes = false;
      postSetup = ''
        ip link set dev ${ifname} mtu 1500
        wg set ${ifname} fwmark ${port}
      '';
      peers = [
        ({
          allowedIPs = [ "0.0.0.0/0" "::/0" ];
      #    publicKey = hostCfg.wireguard.publicKey;
      #    persistentKeepalive = 21;
      #  } // (if (ipv4 && hostCfg.wireguard.endpoint4 != null) then {
      #    endpoint = "${hostCfg.wireguard.endpoint4}:${toString port}";
      #  } else
      #    { }) // (if (!ipv4 && hostCfg.wireguard.endpoint != null) then {
      #      endpoint = "${hostCfg.wireguard.endpoint}:${toString port}";
      #    } else
      #      { }))
        })
      ];
    };

in {
  config = mkIf (cfg.enable && cfg.wireguard.publicKey != null) {
    fluepke.deploy.groups = [ "wireguard-internal" ];

    networking.wireguard.interfaces = 
         mapAttrs' (mkWireguard false) groups.wireguard-internal  # IPv6
      // mapAttrs' (mkWireguard true)  groups.wireguard-internal; # IPv4

  };
}
