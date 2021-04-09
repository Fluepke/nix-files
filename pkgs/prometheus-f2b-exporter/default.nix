{ stdenv, lib, buildGoPackage, fetchFromGitHub, nixosTests }:

buildGoPackage rec {
  pname = "prometheus-cachet-exporter";
  version = "master";

  src = fetchFromGitHub {
    owner = "glvr182";
    repo = "f2b-exporter";
    sha256 = "0sl9gv57yy5vscf6drlgspwp1hp4qwm84jrzfypqd060zrhsj364";
    rev = "cdc82755bb4e6212ec1226ef90b32a58d552fc31";
  };

  goPackagePath = "github.com/glvr182/f2b-exporter";

  goDeps = ./deps.nix;

  meta = with lib; {
    description = "This is a simple Fail2Ban prometheus exporter";
    homepage = "https://github.com/glvr182/f2b-exporter";
    license = licenses.asl20;
    maintainers = with maintainers; [ fluepke ];
    platforms = platforms.unix;
  };
}
