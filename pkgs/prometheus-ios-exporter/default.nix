{ stdenv, lib, buildGoPackage, nixosTests }:

buildGoPackage rec {
  pname = "prometheus-ios-exporter";
  version = "latest";

  src = ./prometheus-ios-exporter;

  goPackagePath = "prometheus-ios-exporter";
  goDeps = ./prometheus-ios-exporter/deps.nix;

  meta = with lib; {
    description = "Exports metrics from Apple iOS devices";
    license = licenses.mit;
    maintainers = with maintainers; [ fluepke ];
    platforms = platforms.linux;
  };
}
