{ config }:

{
  inberlin = {
    asn = 29670;
    ip = "2001:67c:1400::1";
    ip4 = "217.197.83.130";
    sourceIp = "2001:67c:1400:20b0::1";
    sourceIp4 = "217.197.83.150";
    upstream = true;
    extraConfig = ''
      include "${config.fluepke.secrets.inberlin-password-conf.path}";
    '';
  };
}
