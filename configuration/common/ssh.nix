{ config, pkgs, lib, ... }:

let
  sshPort = 42023;
  hostKeyFromSecrets = builtins.pathExists (../../secrets + "/${config.fluepke.deploy.fqdn}/ssh-host.key.gpg");
in
{
  networking.firewall.allowedTCPPorts = [ sshPort 22 ];

  fluepke.secrets."ssh-host.key" = lib.mkIf hostKeyFromSecrets {};

  services.openssh = {
    enable = true;
    permitRootLogin = lib.mkDefault "no";
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
    extraConfig = ''
      AuthenticationMethods publickey
    '';
    hostKeys = lib.mkIf hostKeyFromSecrets [{
      path = config.fluepke.secrets."ssh-host.key".path;
      type = "ed25519";
    }];
    ports = [ sshPort 22 ];
    banner = "
                                             _,'/
                                        _.-''._:
                                ,-:`-.-'    .:.|
                               ;-.''       .::.|
                _..------.._  / (:.       .:::.|
             ,'.   .. . .  .`/  : :.     .::::.|
           ,'. .    .  .   ./    \\ ::. .::::::.|
         ,'. .  .    .   . /      `.,,::::::::.;\
        /  .            . /       ,',';_::::::,:_:
       / . .  .   .      /      ,',','::`--'':;._;
      : .             . /     ,',',':::::::_:'_,'
      |..  .   .   .   /    ,',','::::::_:'_,'
      |.              /,-. /,',':::::_:'_,'
      | ..    .    . /) /-:/,'::::_:',-'
      : . .     .   // / ,'):::_:',' ;
       \\ .   .     // /,' /,-.','  ./
        \\ . .  `::./,// ,'' ,'   . /
         `. .   . `;;;,/_.'' . . ,'
          ,`. .   :;;' `:.  .  ,'
         /   `-._,'  ..  ` _.-'
        (     _,'``------''  ${config.networking.hostName}.${config.networking.domain}
         `--''
    ";
  };
}
