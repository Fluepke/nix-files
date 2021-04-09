{ config, lib, ... }:

{
  environment.etc."fail2ban/filter.d/refused-connection.conf".text = ''
    [INCLUDES]
    before = common.conf

    [Definition]
    failregex = refused connection: .* SRC=<HOST>
  '';
  services.fail2ban = {
    enable = true;
    ignoreIP = [
      "40.158.40.0/22"
    ];
    jails = {
      sshd = ''
        enabled = true
        filter = sshd
        maxfailures = 2
      '';
      nginx-botsearch = ''
        enabled = true
        filter = nginx-http-botsearch
        maxfailures = 5
      '';
      refused-connection = ''
        enabled = true
        backend = systemd
        journalmatch = SYSLOG_FACILITY=0 PRIORITY=6
        maxretry = 3
        findtime = 5
        bantime = 120
        ignoreip = ${lib.concatStringsSep " " config.services.fail2ban.ignoreIP}
      '';
    };
  };

  fluepke.monitoring.prometheus-f2b-exporter.enable = true;
}
