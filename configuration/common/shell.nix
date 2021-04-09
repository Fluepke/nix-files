{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    shellInit = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source ${./p10k.zsh}

      # see https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md
      # ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=$POWERLEVEL9K_STATUS_ERROR_FOREGROUND,bold
      # ZSH_HIGHLIGHT_STYLES[command]=fg=white,bold
      # ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=blue
      # ZSH_HIGHLIGHT_STYLES[alias]=$ZSH_HIGHLIGHT_STYLES[command],underline
      # ZSH_HIGHLIGHT_STYLES[builtin]=$ZSH_HIGHLIGHT_STYLES[command]
      # ZSH_HIGHLIGHT_STYLES[path]=fg=$POWERLEVEL9K_DIR_FOREGROUND
      zsh-newuser-install() { :; }
    '';
    histSize = 100000;
    autosuggestions = {
      enable = true;
      extraConfig = {
        "ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE" = "420";
      };
    };
    syntaxHighlighting.enable = true;
    syntaxHighlighting.highlighters = [ "main" "brackets" ];
  };
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
