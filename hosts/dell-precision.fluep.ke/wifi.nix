{ config, ... }:

{
  networking.wireless.enable = true;

  fluepke.secrets."wpa_supplicant.conf" = {};
  environment.etc."wpa_supplicant.conf".source = config.fluepke.secrets."wpa_supplicant.conf".path;
}
