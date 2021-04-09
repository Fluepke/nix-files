{ stdenv, lib, buildGoPackage, fetchFromGitHub, nixosTests }:

buildGoPackage rec {
  pname = "vodafone-station-exporter";
  version = "master";

  src = fetchFromGitHub {
    owner = "fluepke";
    repo = "vodafone-station-exporter";
    sha256 = "0kg2i1pxvmlpzhkdh35rnc5al2zq6156ljb6v96giqnm0k6sv6iq";
    rev = "ee0ce195ec1278034f5f51175c9382db83c6712f";
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
