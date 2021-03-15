let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {};
in {
  kexec_tarball = import ./lib/kexec-tarball.nix { inherit pkgs; };
  deploy = import ./lib/deploy.nix { inherit pkgs; };
}
  // (import ./lib/hosts.nix { inherit pkgs; })
