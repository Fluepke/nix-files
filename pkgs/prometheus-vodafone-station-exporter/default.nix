{ stdenv, lib, buildGoPackage, fetchFromGitHub, nixosTests }:

buildGoPackage rec {
  pname = "prometheus-vodafone-station-exporter";
  version = "master";

  src = fetchFromGitHub {
    owner = "fluepke";
    repo = "vodafone-station-exporter";
    sha256 = "0dz85c16fc83892ssrfbbmw9snc9kp82b7dk7fs0lj7y7bzn2k6l";
    rev = "547172a8e30f25a0b34edd126ff1ba16dd1024d5";
  };

  goPackagePath = "github.com/fluepke/vodafone-station-exporter";
  goDeps = ./deps.nix;

  meta = with lib; {
    description = "Prometheus exporter for Vodafone Station (CGA4233DE)";
    homepage = "https://github.com/Fluepke/vodafone-station-exporter";
    license = licenses.mit;
    maintainers = with maintainers; [ fluepke ];
    platforms = platforms.linux;
  };
}
