{ stdenv, lib, buildGoPackage, nixosTests }:

buildGoPackage rec {
  pname = "prometheus-zyxel-exporter";
  version = "latest";

  src = ./prometheus-zyxel-exporter;

  goPackagePath = "prometheus-zyxel-exporter";
  goDeps = ./deps.nix;

  meta = with lib; {
    description = "Exports metrics from weird Zyxel PoE switches";
    license = licenses.mit;
    maintainers = with maintainers; [ fluepke ];
    platforms = platforms.linux;
  };
}
