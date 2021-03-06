{ pkgs }:

with pkgs.lib;

let
  inherit (import ./hosts.nix { inherit pkgs; }) hosts groups;

in (
  mapAttrs (name: hosts: pkgs.writeScript "deploy-group-${name}" ''
    #!${pkgs.runtimeShell}
    export PATH=

    ${concatMapStrings (host: ''
      echo "deploying ${host.config.networking.hostName}..."
      ${host.config.system.build.deployScript} $1 &
      PID_LIST+=" $!"
    '') hosts}

    # FIXME: remove jobs from PIDLIST once they finish
    trap "kill $PID_LIST" SIGINT
    wait $PID_LIST
  '') groups
)
 // (mapAttrs (name: host: host.config.system.build.deployScript) hosts)

