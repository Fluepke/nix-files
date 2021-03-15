{ pkgs, config, lib, ... }:

with lib;

let
  secret-file = types.submodule ({ ... }@moduleAttrs: {
    options = {
      name = mkOption {
        type = types.str;
        default = moduleAttrs.config._module.args.name;
      };
      path = mkOption {
        type = types.str;
        readOnly = true;
        default = "/run/secrets/${removeSuffix ".gpg" (baseNameOf moduleAttrs.config.source-path)}";
      };
      mode = mkOption {
        type = types.str;
        default = "0400";
      };
      owner = mkOption {
        type = types.str;
        default = "root";
      };
      group-name = mkOption {
        type = types.str;
        default = "root";
      };
      source-path = mkOption {
        type = types.str;
        default = "${../../secrets + "/${config.fluepke.deploy.fqdn}/${moduleAttrs.config.name}.gpg"}";
      };
      encrypted = mkOption {
        type = types.bool;
        default = true;
      };
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  });
  enabledFiles = filterAttrs (n: file: file.enable) config.fluepke.secrets;
  
  mkDeploySecret = file: pkgs.writeScript "deploy-secret-${removeSuffix ".gpg" (baseNameOf file.source-path)}.sh" ''
    #!${pkgs.runtimeShell}
    set -eu pipefail
    if [ ! -f "${file.path}" ]; then
      umask 0077
      echo "${file.source-path} -> ${file.path}"
      ${if file.encrypted then ''
        ${pkgs.gnupg}/bin/gpg --decrypt ${escapeShellArg file.source-path} > ${file.path}
      '' else ''
        cat ${escapeShellArg file.source-path} > ${file.path}
      ''}
    fi
    chown ${escapeShellArg file.owner}:${escapeShellArg file.group-name} ${escapeShellArg file.path}
    chmod ${escapeShellArg file.mode} ${escapeShellArg file.path}
  '';
in 
{
  options.fluepke.secrets = mkOption {
    type = with types; attrsOf secret-file;
    default = {};
  };
  config = {
    system.activationScripts.setup-secrets = let
    files = unique (map (flip removeAttrs ["_module"]) (attrValues enabledFiles));
    gnupgScript = ''
      %echo Generating a OpenPGP key
      Key-Type: eddsa
      Key-Curve: Ed25519
      Key-Usage: sign,auth
      Subkey-Type: ecdh
      Subkey-Curve: Curve25519
      Subkey-Usage: encrypt
      Name-Comment: ${config.fluepke.deploy.fqdn}
      Preferences: SHA512 AES256 Uncompressed
      Expire-Date: 0
    '';
    gnupgScriptFile = pkgs.writeText "gnupg-gen-key-script" gnupgScript;
    script = ''
      PUBKEYFILE=/var/src/$(hostname -f).gpg
      
      mkdir -p /var/src
      if [ ! -s $PUBKEYFILE ]; then
          ${pkgs.gnupg}/bin/gpg2 --batch --passphrase "" --pinentry-mode loopback --gen-key ${gnupgScriptFile}
          ${pkgs.gnupg}/bin/gpg2 --export -a $(hostname -f) > /var/src/$(hostname -f).gpg
      fi

      echo setting up /run/secrets...
      mkdir -p /run/secrets
      chown root:root /run/secrets
      chmod 0755 /run/secrets
      ${concatMapStringsSep "\n" (file: ''
        ${mkDeploySecret file} || echo "failed to deploy ${file.source-path} to ${file.path}"
      '') files}
      ''; in
      stringAfter [ "users" "groups" ] "source ${pkgs.writeText "setup-secrets.sh" script}";
  };
}
