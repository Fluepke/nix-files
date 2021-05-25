{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.petabyte.network;

  peerOpts = { ... }: {
    options = {
      asn = mkOption {
        type = types.int;
      };
      ip = mkOption {
        type = with types; nullOr str;
        default = null;
      };
      ip4 = mkOption {
        type = with types; nullOr str;
        default = null;
      };
      sourceIp = mkOption {
        type = with types; nullOr str;
        default = null;
      };
      sourceIp4 = mkOption {
        type = with types; nullOr str;
        default = null;
      };
      downstreams = mkOption {
        type = with types; listOf int;
        default = [];
      };
      downstreamSet = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      upstream = mkOption {
        type = types.bool;
        default = false;
      };
      downstream = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  ospfIfaceOpts = { ... }: {
    options = {
      p2p = mkOption {
        type = types.bool;
        default = false;
      };
      cost = mkOption {
        type = types.int;
      };
    };
  };
in {
  imports = [ /*./bird*/ ./wireguard.nix /*./rpki.nix*/ ];

  options = rec {
    petabyte.network = {
      enable = mkEnableOption "PetaByte Network";
      rpki = mkOption {
        type = types.bool;
        default = cfg.peers != {};
      };
      magicNumber = mkOption {
        type = types.int;
      };
      peers = mkOption {
        type = with types; attrsOf (submodule peerOpts);
        default = {};
      };
      downstreams = mkOption {
        type = types.attrs;
        default = {};
      };
      hosts = mkOption {
        type = with types; attrsOf attrs;
      };
      localAS = mkOption {
        type = types.int;
      };
      primaryIP = mkOption {
        type = types.str;
      };
      primaryIP4 = mkOption {
        type = types.str;
      };
      earlyExtraConfig = mkOption {
        type = types.lines;
        default = "";
      };
      extraConfig = mkOption {
        type = types.lines;
        default = "";
      };
      importFilter = mkOption {
        type = types.lines;
      };
      exportFilter = mkOption {
        type = types.lines;
      };
      internal = mkOption {
        type = types.bool;
        default = false;
      };
      wireguard = {
        enable = mkOption {
          type = types.bool;
          default = true;
        };
        PublicKey = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        Endpoint = mkOption {
          type = with types; nullOr str;
          default = null;
        };
        Endpoint4 = mkOption {
          type = with types; nullOr str;
          default = null;
        };
        hasLocationTunnelPrefix = mkOption {
          type = types.bool;
          default = false;
        };
        hasLocationTunnelPrefix4 = mkOption {
          type = types.bool;
          default = false;
        };
      };
      ospf = {
        enable = mkOption {
          type = types.bool;
          default = true;
        };
        instanceId = mkOption {
          type = with types; nullOr int;
          default = null;
        };
        interfaces = mkOption {
          type = with types; attrsOf (submodule ospfIfaceOpts);
          default = {};
        };
        extraConfig = mkOption {
          type = types.lines;
          default = "";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    fluepke.deploy.groups = [ "network" ];

    #petabyte.nftables = let
    #  mtuFix = ''
    #    meta nfproto ipv6 tcp flags syn tcp option maxseg size 1365-65535 tcp option maxseg size set 1364
    #    meta nfproto ipv4 tcp flags syn tcp option maxseg size 1385-65535 tcp option maxseg size set 1384
    #  '';
    #in {
    #  forwardPolicy = "accept";
    #  extraInput = mtuFix + ''
    #    meta l4proto ospfigp accept
    #  '';
    #  extraForward = mtuFix;
    #  extraOutput = mtuFix;
    #};

    networking.firewall.allowedTCPPorts = [ 179 ];
    networking.firewall.checkReversePath = false;
    users.users.fluepke.extraGroups = [ "bird2" ];
    boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = true;
    boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = true;

    networking.interfaces.lo.ipv6.addresses = [{
      address = cfg.primaryIP;
      prefixLength = 128;
    }];
    networking.interfaces.lo.ipv4.addresses = [{
      address = cfg.primaryIP4;
      prefixLength = 32;
    }];

    environment.etc."systemd/networkd.conf".source = pkgs.writeText "networkd.conf" ''
      [Network]
      ManageForeignRoutes=false
    '';

    systemd.network.networks."40-lo".routingPolicyRules = [
      {
        routingPolicyRuleConfig = {
          Family = "both";
          SuppressPrefixLength = 0;
          Priority = 1000;
        };
      }
      {
        routingPolicyRuleConfig = {
          Family = "both";
          Table = 1; # location not in local network; bgp
          Priority = 6000;
        };
      }
      {
        routingPolicyRuleConfig = {
          Family = "both";
          Table = 2; # location in local network; ospf
          Priority = 7000;
        };
      }
    ];
  };
}
