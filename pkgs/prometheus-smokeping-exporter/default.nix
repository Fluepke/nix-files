{ stdenv, lib, buildGoPackage, fetchFromGitHub, nixosTests }:

buildGoPackage rec {
  pname = "prometheus-smokeping-exporter";
  version = "v0.3.0";

  src = fetchFromGitHub {
    owner = "SuperQ";
    repo = "smokeping_prober";
    sha256 = "088c8lp07k7j7d76ikk6j1sz8hh2jh12bgbxpdj59s93nn4ccsfa";
    rev = "v0.3.0";
  };

  goPackagePath = "github.com/SuperQ/smokeping_prober";

  goDeps = ./deps.nix;

  meta = with lib; {
    description = "Prometheus style smokeping prober";
    homepage = "https://github.com/SuperQ/smokeping_prober";
    license = licenses.asl20;
    maintainers = with maintainers; [ fluepke ];
    platforms = platforms.unix;
  };
}
