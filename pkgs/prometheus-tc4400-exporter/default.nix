{ stdenv, lib, buildGoPackage, fetchFromGitHub, nixosTests }:

buildGoPackage rec {
  pname = "prometheus-tc4400-exporter";
  version = "master";

  src = fetchFromGitHub {
    owner = "markuslindenberg";
    repo = "tc4400_exporter";
    sha256 = "13l2dxj2jmxdx4gmvqjjvykv1yaz3mkgynjqlnq69n0ynbxynk6y";
    rev = "de20d50b061228cc198c80b6e1e08d4e5469aa45";
  };

  goPackagePath = "github.com/markuslindenberg/tc4400_exporter";

  goDeps = ./deps.nix;

  meta = with lib; {
    description = "Prometheus TC4400 Exporter";
    homepage = "https://github.com/markuslindenberg/tc4400_exporter";
    license = licenses.asl20;
    maintainers = with maintainers; [ fluepke ];
    platforms = platforms.unix;
  };
}
