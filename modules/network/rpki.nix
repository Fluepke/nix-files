{ pkgs, config, lib, ... }:

let
  cfg = config.petabyte.network;
in {
  config = lib.mkIf (cfg.enable && cfg.rpki) {
    petabyte.network.earlyExtraConfig = ''
      roa6 table t_roa6;
      roa4 table t_roa4;

      protocol rpki routinator1 {
        roa4 { table t_roa4; };
        roa6 { table t_roa6; };
        remote "${cfg.primaryIP4}" port 3323;
        retry keep 90;
        refresh keep 900;
        expire keep 172800;
      }
    '';

    systemd.services.gortr = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig.DynamicUser = true;
      script =
        "gortr -refresh=60 -cache=https://rpki-validator.ripe.net/api/export.json -verify=false -checktime=false -bind=:3323";
      path = [ pkgs.gortr ];
    };
  };
}
