{ pkgs, groups, config, lib, ... }:

with lib;

let
  cfg = config.petabyte.network;

  toAddressBlock = x: { addressConfig.Address = x; };

  mkWireguard = ipv4: host:
    let
      inherit (host.config.networking) hostName;
      ifname = if ipv4 then "wg-4-${hostName}" else "wg-6-${hostName}";
      hostCfg = host.config.petabyte.network;

      # cfg.locationTunnelPrefix neighbour.locationTunnelPrefix
      # 0                        0                              lookup main
      # 0                        1                              lookup 2
      # 1                        0                              loopup main
      # 1                        1                              lookup 2
      hasTunnelPrefix = (
        if ipv4 then
          hostCfg.wireguard.hasLocationTunnelPrefix4
        else
          hostCfg.wireguard.hasLocationTunnelPrefix
      ) != null;

    in rec {
      port = (if ipv4 then 52820 else 51820) + hostCfg.magicNumber + cfg.magicNumber;

      ospfIface = nameValuePair ifname {
        p2p = true;
        cost = if ipv4 then 80 else 50;
      };

      netdev = nameValuePair "40-${ifname}" {
        netdevConfig = {
          Name = ifname;
          Kind = "wireguard";
          MTUBytes = "1500";
        };
        wireguardConfig = {
          PrivateKeyFile = config.fluepke.secrets.wireguard.path;
          ListenPort = port;
          FirewallMark = port;
        };
        wireguardPeers = [
          {
            wireguardPeerConfig = {
              AllowedIPs = [ "0.0.0.0/0" "::/0" ];
              PublicKey = hostCfg.wireguard.PublicKey;
              PersistentKeepalive = 21;
            } // optionalAttrs (ipv4 && hostCfg.wireguard.Endpoint4 != null) {
              Endpoint = "${hostCfg.wireguard.Endpoint4}:${toString port}";
            } // optionalAttrs (!ipv4 && hostCfg.wireguard.Endpoint != null) {
              Endpoint = "${hostCfg.wireguard.Endpoint}:${toString port}";
            };
          }
        ];
      };

      network = nameValuePair "40-${ifname}" {
        name = ifname;
        addresses = map toAddressBlock[
          "fe80::${toString cfg.magicNumber}/64"
          "169.254.0.${toString cfg.magicNumber}/16"
        ];
        routingPolicyRules = (optionals hasTunnelPrefix [
          {
            routingPolicyRuleConfig = {
              Family = "both";
              FirewallMark = port;
              Priority = 2900;
              Table = 2;
            };
          }
        ]) ++ [
          {
            routingPolicyRuleConfig = {
              Family = "both";
              FirewallMark = port;
              Priority = 3000;
            };
          }
          #{
          #  routingPolicyRuleConfig = {
          #    Family = "both";
          #    FirewallMark = port;
          #    Type = "unreachable";
          #    Priority = 3001;
          #  };
          #}
        ];
      };
    };

  notSelf = x: x.config.networking.hostName != config.networking.hostName;

  ifaces = (map (mkWireguard false) (filter notSelf groups.wireguard-internal)) # IPv6
        ++ (map (mkWireguard true) (filter notSelf groups.wireguard-internal)); # IPv4

in {
  config = mkIf (cfg.enable && cfg.wireguard.enable) {
    fluepke.deploy.groups = [ "wireguard-internal" ];
    fluepke.secrets.wireguard.owner = "systemd-network";
    environment.systemPackages = with pkgs; [ wireguard-tools ];

    networking.firewall.allowedUDPPorts = map (x: x.port) ifaces;
    #petabyte.network.ospf.interfaces = listToAttrs (map (x: x.ospfIface) (filter (x: x ? ospfIface) ifaces));
    systemd.network.netdevs = listToAttrs (map (x: x.netdev) ifaces);
    systemd.network.networks = listToAttrs (map (x: x.network) ifaces);
  };
}
