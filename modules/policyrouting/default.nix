{ config, lib, ... }:

with lib;

let
  cfg = config.petabyte.policyrouting;

  ruleOpts = { ... }: {
    options = {
      prio = mkOption {
        type = types.int;
      };
      rule = mkOption {
        type = types.str;
      };
    };
  };

in {
  options = {
    petabyte.policyrouting = {
      enable = mkEnableOption "Declarative Policy-Routing";
      rules = mkOption {
        type = with types; listOf (submodule ruleOpts);
        default = [];
      };
      rules6 = mkOption {
        type = with types; listOf (submodule ruleOpts);
        default = [];
      };
      rules4 = mkOption {
        type = with types; listOf (submodule ruleOpts);
        default = [];
      };
    };
  };

  config = mkIf cfg.enable {
    petabyte.policyrouting.rules = [
      { rule = "lookup main"; prio = 32000; }
    ];
    networking.localCommands = ''
      set -x
      ip -6 rule flush
      ip -4 rule flush
      ${concatMapStringsSep "\n" ({ prio, rule }: "ip -6 rule add ${rule} prio ${toString prio}") (cfg.rules ++ cfg.rules6)}
      ${concatMapStringsSep "\n" ({ prio, rule }: "ip -4 rule add ${rule} prio ${toString prio}") (cfg.rules ++ cfg.rules4)}
    '';
  };
}
