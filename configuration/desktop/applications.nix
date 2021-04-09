{ lib, config, pkgs, ... }:

{
  users.users.fluepke.packages = with pkgs; [
    cargo rustc rustfmt
    gnumake gcc binutils cmake
    pass
    gcc
    yarn
    nodejs
    python3
    xournal
    ansible
    ncat
    pwgen
    mpc_cli
    powertop
    qemu
    deluge
    imagemagick
    gimp
    inkscape
    thunderbird
    dino
    sshfs
    quasselClient
    pavucontrol
    tdesktop
    evince
    youtubeDL
    mumble
    screen # for usb serial
    gmpc
    ecdsautils
    libarchive # for bsdtar
    gpodder
    cpufrequtils
    ffmpeg
    nim
    aria2
    patchelf
    brightnessctl
    multimc
    coreboot-utils
    me_cleaner
    flashrom
    hcloud
    virtmanager
    firefox-wayland
    jitsi-meet-electron
    tightvnc
    imv
    fusee-launcher
    unzip
    nix-prefetch-git
    nix-prefetch-github
    restic
    tipp10
    jdk
    gradle
    jetbrains.idea-ultimate
    jd-gui
    #jetbrains.webstorm
    xdg_utils
    dconf
    hicolor-icon-theme

    rust-analyzer
    cargo-watch
    thunderbird
    tdesktop

    thunderbolt
    bolt

    kicad-with-packages3d

    #doom-emacs
    #(lib.hiPrio (pkgs.writeScriptBin "emacs" ''
    #  #!${pkgs.runtimeShell}
    #  exec ${doom-emacs}/bin/emacsclient -c "$@" &
    #''))
  ];

  home-manager.users.fluepke = {
    programs.git = {
      package = pkgs.gitFull;
      extraConfig = {
        user = {
          name = "Fabian Lüpke";
          email = "fabian@luepke.email";
          username = "fluepke";
          signingkey = "0820A3CAD614B734";
        };
        core = {
          editor = "vim";
          whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
        };
        features.manyFiles = true;
      };
    };

    #programs.chromium = {
    #  enable = true;
    #  extensions = [
    #    "gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
    #    "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
    #  ];
    #};

    programs.mpv.enable = true;

    programs.gpg.enable = true;
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryFlavor = "qt";
      enableExtraSocket = true;
      # sshKeys = [ "725BE099" "61AE846D95B38061E2AC2E265A94251FF87C2FEE" ];
    };

    #programs.password-store.enable = true;
    #password-store-sync.enable = true;

    xdg.enable = true;
    xdg.mime.enable = true;
    xdg.mimeApps.enable = true;
    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/http"       = "firefox.desktop";
      "x-scheme-handler/https"      = "firefox.desktop";
      "x-scheme-handler/chrome"     = "firefox.desktop";

      "x-scheme-handler/mailto"     = "thunderbird.desktop";
      "x-scheme-handler/xmpp"       = "dino.desktop";

      "x-scheme-handler/rtmp"       = "mpv.desktop";
      "x-scheme-handler/rtsp"       = "mpv.desktop";

      "image/svg+xml"               = "imv.desktop";
      "image/jpeg"                  = "imv.desktop";
      "image/jpeg2000"              = "imv.desktop";
      "image/png"                   = "imv.desktop";

      "application/pdf"             = [ "evince.desktop" "qutebrowser.desktop" ];

      "application/ogg"             = "mpv.desktop";
      "application/x-ogg"           = "mpv.desktop";
      "application/x-flac"          = "mpv.desktop";
      "application/x-extension-mp4" = "mpv.desktop";

      "content/audio-player"        = "mpv.desktop";
      "audio/mp4"                   = "mpv.desktop";
      "audio/mpeg"                  = "mpv.desktop";
      "audio/webm"                  = "mpv.desktop";
      "audio/flac"                  = "mpv.desktop";
      "audio/ogg"                   = "mpv.desktop";
      "audio/x-flac"                = "mpv.desktop";
      "audio/x-m4a"                 = "mpv.desktop";
      "audio/x-matroska"            = "mpv.desktop";
      "audio/x-mp3"                 = "mpv.desktop";
      "audio/x-mpeg"                = "mpv.desktop";
      "audio/x-vorbis+ogg"          = "mpv.desktop";
      "audio/x-wav"                 = "mpv.desktop";

      "video/ogg"                   = "mpv.desktop";
      "video/mp4"                   = "mpv.desktop";
      "video/mp4v"                  = "mpv.desktop";
      "video/mpeg"                  = "mpv.desktop";
      "video/webm"                  = "mpv.desktop";
      "video/x-avi"                 = "mpv.desktop";
      "video/x-matroska"            = "mpv.desktop";
      "video/x-mpeg"                = "mpv.desktop";

      "text/html"                   = "qutebrowser.desktop";
      "text/xml"                    = "qutebrowser.desktop";
      #"text/csv"                    = "sublime3.desktop";
      #"text/plain"                  = "sublime3.desktop";
    };

    gtk = {
      enable            = true;
      iconTheme.name    = "Adwaita";
      iconTheme.package = pkgs.gnome3.adwaita-icon-theme;

      gtk3 = {
        extraConfig  = {
          gtk-application-prefer-dark-theme = true;
        };
      };
    };

    #home.file.".gnupg/sshcontrol".text = ''
    #  725BE099

    #  # SHA256:D7SV/Uj+lDXsNBsbaE9JgB5SxIsFIi0aSw/+kfWSEqs
    #  61AE846D95B38061E2AC2E265A94251FF87C2FEE 0
    #'';

    programs.zsh.initExtra = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        exec sway
      fi
    '';
  };

  systemd.user.services.emacs.wantedBy = [ "graphical-session.target" ];

  systemd.user.services.qutebrowser = {
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session-pre.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.qutebrowser}/bin/qutebrowser --nowindow";
      Restart = "always";
      RestartSec = 3;
    };
    environment.PATH = lib.mkForce "/run/wrappers/bin:/home/fluepke/.nix-profile/bin:/etc/profiles/per-user/fluepke/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
  };

  fonts.fontconfig.localConf = lib.fileContents ./fontconfig.xml;
  fonts.fontconfig.defaultFonts = {
    emoji = ["Noto Color Emoji"];
    serif = ["Bitstream Vera Serif"];
    sansSerif = ["Bitstream Vera Sans"];
    monospace = ["Bitstream Vera Sans Mono"];
  };
  fonts.fonts = with pkgs; [
    noto-fonts-emoji
    emacs-all-the-icons-fonts
    ttf_bitstream_vera
    font-awesome_4
    fira-mono
    unifont
    nerdfonts
  ];

  environment.variables.SSH_AUTH_SOCK = "/run/user/1000/gnupg/S.gpg-agent.ssh";

  services.udev.packages = [ pkgs.hackrf ];
  users.groups.plugdev = {};
  users.users.fluepke.extraGroups = [ "wireshark" "adbusers" "dialout" "plugdev" ];
  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark-qt;
  nixpkgs.config.android_sdk.accept_license = true;
  programs.adb.enable = true;
  #programs.geary.enable = true;
  services.pcscd.enable = true;
}
