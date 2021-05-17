{ pkgs, config, lib, ... }:

with lib;

{
  imports = [
    ./wireguard.nix
    ./policy-routing.nix
  ];

  options = {
    fluepke.network = {
      enable = mkEnableOption "fluepke network";

      magicNumber = mkOption {
        type = types.int;
      };

      # location-specific subnet, that is propagated via IBGP
      # SHOULD be part of a less-specific for redundancy reasons
      locationAnnouncement = mkOption {
        type = types.nullOr types.str;
      };

      # location-specific subnet, that is not propagated via IBGP
      # MUST NOT be part of a less-specific
      locationTunnelAnnouncement = mkOption {
        type = types.nullOr types.str;
      };

      # location-specific subnet, that is propagated via IBGP
      # SHOULD be part of a less-specific for redundancy reasons
      locationAnnouncement4 = mkOption {
        type = types.nullOr types.str;
      };

      # location-specific subnet, that is not propagated via IBGP
      # MUST NOT be part of a less-specific
      locationTunnelAnnouncement4 = mkOption {
        type = types.nullOr types.str;
      };

      wireguard = {
        publicKey = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        endpoint = mkOption {
          type = with types; nullOr str;
          default = null;
        };
        endpoint4 = mkOption {
          type = with types; nullOr str;
          default = null;
        };
      };
    };
  };
}
