{ config, pkgs, lib, ... }:

let
  sshPort = 42023;
in
{
  networking.firewall.allowedTCPPorts = [ sshPort 22 ];

  fluepke.secrets."ssh-host.key" = {};

  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
    extraConfig = ''
      AuthenticationMethods publickey
    '';
    hostKeys = [{
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
