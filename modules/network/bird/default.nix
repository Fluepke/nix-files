{ groups, config, lib, pkgs, ... }:

let
  cfg = config.petabyte.network;

  mkHost = host: let
    name = host.config.networking.hostName;
  in ''
    protocol bgp bgp_internal_${name} from bgp_all {
      ipv6 {
        igp table ospf6;
        import keep filtered;
        import filter {
          bgp_local_pref = 50;
          ${host.config.petabyte.network.importFilter}
          accept;
        };
        export filter {
          if ((0, 0, 0)) ~ bgp_large_community then reject;
          if ((${toString cfg.localAS}, ${toString cfg.localAS}, 0)) ~ bgp_large_community then reject;
          ${host.config.petabyte.network.exportFilter}
          accept;
        };
      };
      ipv4 {
        igp table ospf4;
        import keep filtered;
        import filter {
          bgp_local_pref = 50;
          ${host.config.petabyte.network.importFilter}
          accept;
        };
        export filter {
          if ((0, 0, 0)) ~ bgp_large_community then reject;
          if ((${toString cfg.localAS}, ${toString cfg.localAS}, 0)) ~ bgp_large_community then reject;
          ${host.config.petabyte.network.exportFilter}
          accept;
        };
      };
      source address ${cfg.primaryIP};
      neighbor ${host.config.petabyte.network.primaryIP} as ${toString host.config.petabyte.network.localAS};
    }
  '';
  mkPeer = pname: peer: let
    name = if peer.upstream then
      "upstream_${pname}"
    else (if peer.downstream then
      "downstream_${pname}"
    else
      "peer_${pname}");

    downstreams = cfg.downstreams.${pname};
    peerAs = toString peer.asn;
  in
    ''
      filter ${name}_import {
        # reject long as paths
        if bgp_path.len > 64 then {
          print "[internet in] as-path ge 64, rejecting: ", net, " ASN ", bgp_path.last;
          reject;
        }
        # reject small prefixes
        if net.type = NET_IP4 then {
          if net.len > 24 then {
            print "[internet in] small ipv4 prefix, rejecting: ", net, " ASN ", bgp_path.last;
            reject;
          }
        } else {
          if net.len > 48 then {
            print "[internet in] small ipv6 prefix, rejecting: ", net, " ASN ", bgp_path.last;
            reject;
          }
        }
        # reject bogons
        if net_bogon() then {
          print "[internet in] prefix bogon, rejecting: ", net, " ASN ", bgp_path.last;
          reject;
        }
        if as_bogon() then {
          print "[internet in] as bogon, rejecting: ", net, " ASN ", bgp_path.last;
          reject;
        }

        # honor graceful shutdown
        if (65535, 0) ~ bgp_community then {
          print "[internet in] honoring graceful shutdown, setting pref to 0: ", net, " ASN ", bgp_path.last;
          bgp_local_pref = 0;
        }

    '' + lib.optionalString (peer.upstream) ''
        # print own as
        if bgp_path ~ [ ${toString cfg.localAS} ] then {
          print "[internet in] own as, rejecting: ", net, " ASN ", bgp_path.first;
          bgp_large_community.add ((0, 0, 0)); # not export
        } else if net_local() then {
          print "[internet in] received own prefix, rejecting: ", net, " ASN ", bgp_path.last;
          reject;
        }

    '' + lib.optionalString (!peer.upstream) ''
        # reject own prefixes ingress
        if net_local() then {
          print "[internet in] received own prefix, rejecting: ", net, " ASN ", bgp_path.last;
          reject;
        }

        if ! (bgp_path.first = ${peerAs} && bgp_path.last ~ [
          ${
            lib.concatStringsSep ", "
            (map toString (downstreams ++ [ peer.asn ]))
          }
        ]) then {
          print "[peer ${name} in] not a downstream: ", net, " AS_PATH ", bgp_path;
          reject;
        }
    '' + ''
        if (roa_check(t_roa4, net, bgp_path.last_nonaggregated) = ROA_INVALID) then {
          print "[${name} in] roa4 invalid: ", net, " AS_PATH ", bgp_path;
          reject;
        }
        if (roa_check(t_roa6, net, bgp_path.last_nonaggregated) = ROA_INVALID) then {
          print "[${name} in] roa6 invalid: ", net, " AS_PATH ", bgp_path;
          reject;
        }
    '' + lib.optionalString (!peer.downstream) ''
        bgp_large_community.delete ((${toString cfg.localAS}, 23, 42)); # not a downstream
    '' + lib.optionalString (peer.downstream) ''
        bgp_large_community.add ((${toString cfg.localAS}, 23, 42)); # downstream
    '' + ''

        accept;
      }

      filter ${name}_export {
        # avoid exporting bogons
        if net_bogon() then reject;
        if as_bogon() then reject;
        # export own prefixes
        if ((0, 0, 0)) ~ bgp_large_community then reject;
        if ((${toString cfg.localAS}, 23, 42)) ~ bgp_large_community then {
          #bgp_large_community.delete ((${toString cfg.localAS}, 23, 42));
          accept;
        }
    '' + lib.optionalString (!peer.downstream) ''
        if !net_local() then reject;
    '' + ''
        accept;
      }

    '' + lib.optionalString (peer.ip != null) ''
      protocol bgp bgp_${name}_ipv6 from bgp_all {
        source address ${peer.sourceIp};
        neighbor ${peer.ip} as ${peerAs};
        ${peer.extraConfig}
        ipv6 {
          igp table ospf6;
          next hop self;
          import keep filtered;
          import filter ${name}_import;
          export filter ${name}_export;
        };
      }

    '' + lib.optionalString (peer.ip4 != null) ''
      protocol bgp bgp_${name}_ipv4 from bgp_all {
        source address ${peer.sourceIp4};
        neighbor ${peer.ip4} as ${peerAs};
        ${peer.extraConfig}
        ipv4 {
          igp table ospf4;
          next hop self;
          import keep filtered;
          import filter ${name}_import;
          export filter ${name}_export;
        };
      }
    '';

  mkOspfIface = name: iface: ''
    interface "${name}" {
      ${lib.optionalString iface.p2p "type pointopoint;"}
      cost ${toString iface.cost};
    };
  '';
  mkOspfProtocol = ipver: lib.optionalString cfg.ospf.enable ''
    protocol ospf v3 ospf_ipv${ipver} {
      ipv${ipver} { table ospf${ipver}; import all; export all; };
      ${lib.optionalString (cfg.ospf.instanceId != null) "instance id ${toString cfg.ospf.instanceId};"}
      area 0 {
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList mkOspfIface cfg.ospf.interfaces)}
        ${cfg.ospf.extraConfig}
      };
    }
  '';
  notSelf = x: x.config.networking.hostName != config.networking.hostName;
in {
  config = lib.mkIf cfg.enable {
    services.bird2.enable = true;
    environment.etc."bird/bird2.conf".source = lib.mkForce (pkgs.substituteAll {
      name = "bird2-${config.networking.hostName}.conf";

      inherit (cfg)
        primaryIP primaryIP4 localAS;

      # the check is run in a sandboxed nix derivation and does not have access to password includes
      checkPhase = ''
        cat $out | sed 's/include.*//g' > temp.conf
        echo $out
        ${pkgs.bird2}/bin/bird -d -p -c temp.conf
      '';

      src = pkgs.writeText "bird2-${config.networking.hostName}-template.conf" (''
        ${cfg.earlyExtraConfig}
        ${lib.fileContents ./bird2.conf}
        ${cfg.extraConfig}
      ''
        + mkOspfProtocol "6"
        + mkOspfProtocol "4"
        + lib.concatStringsSep "\n" (lib.mapAttrsToList mkPeer cfg.peers)
        + lib.concatStringsSep "\n" (map mkHost (lib.filter notSelf groups.network))
      );
    });
  };
}
