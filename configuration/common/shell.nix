{ config, ... }:

{
  programs.bash = {
    shellAliases = {
      ".." = "cd ..";
      use = "nix-shell -p ";
      cat = "bat --style=header ";
      grep = "rg";
      ls = "exa";
      ll = "exa -l";
      la = "exa -la";
      tree = "exa -T";
    };
  };
}
