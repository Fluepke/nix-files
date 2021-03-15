{ stdenv, lib, buildGoPackage, fetchFromGitHub, nixosTests }:

buildGoPackage rec {
  pname = "prometheus-iptables-exporter";
  version = "master";

  src = fetchFromGitHub {
    owner = "retailnext";
    repo = "iptables_exporter";
    sha256 = "1zsbsq6w1s5dm7ybvy9hl6dlvimssgvq37z7nffpsa9ynn0rnzfm";
    rev = "bfae25df93c6cc922f622761df7f1b5a2ea1b3bf";
  };

  goPackagePath = "github.com/retailnext/iptables_exporter";

  meta = with lib; {
    description = "Prometheus exporter for iptables packet and byte counters, written in Go";
    homepage = "https://github.com/retailnext/iptables_exporter";
    license = licenses.asl20;
    maintainers = with maintainers; [ fluepke ];
    platforms = platforms.linux;
  };
}
