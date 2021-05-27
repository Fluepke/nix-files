{ config, ... }:

{
  fluepke.secrets."wg-guenther.key" = {};

  networking.wg-quick.interfaces.wg-guenther = {
    privateKeyFile = config.fluepke.secrets."wg-guenther.key".path;
    address = ["45.158.40.0/32" "2a0f:5381:1::1/128"];
    mtu = 1500;
    peers = [{
      endpoint = "45.158.41.1:51821";
      publicKey = "1xYkFLpAfKlcfmKJtg+hi8H9CAE/s8Spf55/nH+2MWU=";
      allowedIPs = ["0.0.0.0/0" "::/0"];
      persistentKeepalive = 10;
    }];
  };
}
