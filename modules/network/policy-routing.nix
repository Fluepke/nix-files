{ config, lib, ... }:

with lib;

# table main: may or may not contain a default route
# table 1: populated by ospf, handles traffic with destination address in our network
# table 2: populated by bgp,  handles traffic with destination address in the internet

let
  cfg = config.fluepke.network;

  # cfg.locationTunnelPrefix neighbour.locationTunnelPrefix
  # 0                        0                              lookup main
  # 0                        1                              lookup 2
  # 1                        0                              loopup main
  # 1                        1                              lookup 2
  mkWgRules = ipv4: name: host:
    let
      hostCfg = host.config.fluepke.network;
      fwmark = (if ipv4 then 52820 else 51820) + hostCfg.magicNumber + cfg.magicNumber;

      hasTunnelPrefix = (
        if ipv4 then
          hostCfg.locationTunnelPrefix4
        else
          hostCfg.locationTunnelPrefix
      ) != null;

      table = if hasTunnelPrefix then "2" else "main";
    in
      { rule = "fwmark ${toString fwmark} lookup ${table}"; prio = 5000; }
  ;

in {
  config = mkIf cfg.enable {
    petabyte.policyrouting = {
      enable = true;

      rules = [
        { rule = "from all lookup main suppress_prefixlength 0"; prio = 4000; }
        { rule = "not from all fwmark 51820 lookup 1"; prio = 4000; }
      ] ++ (
        # route encapsulated wireguard packets, that might be problematic
        # (have a route via wg in the fulltable), via main / default route
        mapAttrsToList (mkWgRules true) groups.wireguard-internal
      ) ++ (
        mapAttrsToList (mkWgRules false) groups.wireguard-internal
      ) ++ [
        { rule = "from all lookup 2";    prio = 7000; }
        # implicit: lookup main 32000
      ];
    };
  };
}
