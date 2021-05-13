{ config, lib, pkgs, ... }:

{
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  users.users.fluepke.packages = with pkgs; [
    qt5.qtwayland
    grim
    slurp
    wl-clipboard
    #wldash
    wofi
    wf-recorder
    gnome3.gnome-clocks
    gnome3.nautilus
    gnome3.quadrapassel
    gnome3.file-roller
    gnome3.vinagre
    waypipe
  ];

  environment.variables.TERMINAL = "alacritty";
  environment.variables.QT_QPA_PLATFORM = "wayland";
  environment.variables.QT_STYLE_OVERRIDE="adwaita-dark";
  environment.variables.QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  environment.variables._JAVA_AWT_WM_NONREPARENTING = "1";
  environment.variables.QT_AUTO_SCREEN_SCALE_FACTOR = "1";
  environment.variables.GDK_SCALE = "1";

  # be careful with those, they *will* break some applications
  environment.variables.SDL_VIDEODRIVER = "wayland";
  environment.variables.GDK_BACKEND = "wayland";
  environment.variables.QUTE_SKIP_WAYLAND_WEBGL_CHECK = "1";

  systemd.user.services.mako = {
    serviceConfig.ExecStart = "${pkgs.mako}/bin/mako";
    restartTriggers = [
      config.home-manager.users.fluepke.xdg.configFile."mako/config".source
    ];
  };

  home-manager.users.fluepke = {
    programs.alacritty = {
      enable = true;
      settings = {
        font.normal = {
          family = "Bitstream Vera Sans Mono";
          size = 32.0;
        };

        colors = {
          primary = {
            background = "0x000000";
            foreground = "0xeaeaea";
          };

          normal = {
            black =   "0x6c6c6c";
            red =     "0xe9897c";
            green =   "0xb6e77d";
            yellow =  "0xecebbe";
            blue =    "0xa9cdeb";
            magenta = "0xea96eb";
            cyan =    "0xc9caec";
            white =   "0xf2f2f2";
          };

          bright = {
            black =   "0x747474";
            red =     "0xf99286";
            green =   "0xc3f786";
            yellow =  "0xfcfbcc";
            blue =    "0xb6defb";
            magenta = "0xfba1fb";
            cyan =    "0xd7d9fc";
            white =   "0xe2e2e2";
          };
        };

        background_opacity = 0.6;
      };
    };

    programs.mako = {
      enable = true;
      defaultTimeout = 3000;
      borderColor = "#ffffff";
      backgroundColor = "#00000070";
      textColor = "#ffffff";
    };

    services.gammastep = {
      enable = true;
      latitude = "52.52";
      longitude = "13.41";
    };

    home.file.".wallpapers".source = ./wallpapers;

    wayland.windowManager.sway = let
      cfg = config.home-manager.users.fluepke.wayland.windowManager.sway;
      wallpaperCommand = "find ~/.wallpapers/* | shuf -n 1";
      lockCommand = "swaylock -i \`${wallpaperCommand}\`";
      modifier = "Mod4";
      kc = (import ./keycodes.nix).us;
    in {
      enable = true;
      package = pkgs.sway;
      xwayland = true;
      wrapperFeatures.gtk = true;


      extraConfig = ''
        default_border pixel 6
      '';

      config = {
        output = {
          "*" = {
            bg = "\`${wallpaperCommand}\` fill";
          };
          "eDP-1" = {
            scale = "1";
          };
        };

        input."*" = {
          xkb_layout = "us";
          # xkb_variant = "us";
        };

        bars = [];

        fonts = [ "Bitstream Vera Sans 11" ];
        terminal = "alacritty";
        menu = "wofi --show drun";

        startup = [
          /*{ command = ''
              swayidle \
                timeout 300 '${lockCommand}' \
                before-sleep '${lockCommand}' \
                lock '${lockCommand}'
              EOF
            ''; }*/
          { command = "systemctl --user restart mako"; always = true; }
          { command = "systemctl --user restart waybar"; always = true; }
        ];

        keybindings = {
          "${modifier}+Return" = "exec ${cfg.config.terminal}";

          "${modifier}+Left" = "focus left";
          "${modifier}+Down" = "focus down";
          "${modifier}+Up" = "focus up";
          "${modifier}+Right" = "focus right";

          "${modifier}+Shift+Left" = "move left";
          "${modifier}+Shift+Down" = "move down";
          "${modifier}+Shift+Up" = "move up";
          "${modifier}+Shift+Right" = "move right";

          "${modifier}+Shift+space" = "floating toggle";
          "${modifier}+space" = "focus mode_toggle";

          "${modifier}+1" = "workspace 1";
          "${modifier}+2" = "workspace 2";
          "${modifier}+3" = "workspace 3";
          "${modifier}+4" = "workspace 4";
          "${modifier}+5" = "workspace 5";
          "${modifier}+6" = "workspace 6";
          "${modifier}+7" = "workspace 7";
          "${modifier}+8" = "workspace 8";
          "${modifier}+9" = "workspace 9";
          "${modifier}+0" = "workspace 10";

          "${modifier}+Shift+1" = "move container to workspace 1";
          "${modifier}+Shift+2" = "move container to workspace 2";
          "${modifier}+Shift+3" = "move container to workspace 3";
          "${modifier}+Shift+4" = "move container to workspace 4";
          "${modifier}+Shift+5" = "move container to workspace 5";
          "${modifier}+Shift+6" = "move container to workspace 6";
          "${modifier}+Shift+7" = "move container to workspace 7";
          "${modifier}+Shift+8" = "move container to workspace 8";
          "${modifier}+Shift+9" = "move container to workspace 9";
          "${modifier}+Shift+0" = "move container to workspace 10";

          "XF86AudioRaiseVolume" = "exec pactl set-sink-volume $(pacmd list-sinks |awk '/* index:/{print $3}') +5%";
          "XF86AudioLowerVolume" = "exec pactl set-sink-volume $(pacmd list-sinks |awk '/* index:/{print $3}') -5%";
          "XF86AudioMute" = "exec pactl set-sink-mute $(pacmd list-sinks |awk '/* index:/{print $3}') toggle";
          "XF86AudioMicMute" = "exec pactl set-source-mute $(pacmd list-sources |awk '/* index:/{print $3}') toggle";
          "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 2%-";
          "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +2%";
        };

        keycodebindings = {
          "${modifier}+Shift+${kc.x}" = "kill";

          "${modifier}+${kc.d}" = "exec ${cfg.config.menu}";
          "${modifier}+${kc.l}" = "exec ${lockCommand}";

          # "${modifier}+${kc.left}" = "focus left";
          # "${modifier}+${kc.t}" = "focus down";
          # "${modifier}+${kc.r}" = "focus up";
          # "${modifier}+${kc.d}" = "focus right";

          # "${modifier}+Shift+${kc.n}" = "move left";
          # "${modifier}+Shift+${kc.t}" = "move down";
          # "${modifier}+Shift+${kc.r}" = "move up";
          # "${modifier}+Shift+${kc.d}" = "move right";

          "${modifier}+${kc.h}" = "split h";
          "${modifier}+${kc.v}" = "split v";
          "${modifier}+${kc.f}" = "fullscreen toggle";

          "${modifier}+${kc.s}" = "layout stacking";
          "${modifier}+${kc.t}" = "layout tabbed";
          "${modifier}+Shift+${kc.t}" = "layout toggle split";

          "${modifier}+Shift+${kc.c}" = "reload";
          "${modifier}+Shift+${kc.l}" = "exit";

          "${modifier}+${kc.r}" = "mode resize";

          # "${modifier}+Shift+${kc.f}" = "exec pkill electron";
          # "${modifier}+${kc.f}" = "exec schildichat-desktop";
          # "${modifier}+Shift+${kc.q}" = "exec pkill -9 qutebrowser";
          # "${modifier}+${kc.q}" = "exec qutebrowser";
          # "${modifier}+Shift+${kc.u}" = "pkill emacs";
          # "${modifier}+${kc.u}" = "exec emacs";

          "--no-repeat 49" = "exec dbus-send --session --type=method_call --dest=net.sourceforge.mumble.mumble / net.sourceforge.mumble.Mumble.startTalking";
          "--release 49" = "exec dbus-send --session --type=method_call --dest=net.sourceforge.mumble.mumble / net.sourceforge.mumble.Mumble.stopTalking";
        };
      };
    };
  };
  services.waybar = {
    enable = true;
    config = {
      battery = {
        format = "{icon} {capacity}% {time}";
        format-charging = "{icon}  {capacity}%";
        format-icons = [ "" "" "" "" "" ];
        interval = 10;
        states = {
          critical = 20;
          warning = 30;
        };
      };
      clock = {
        format = "{:%a %Y-%m-%d %H:%M:%S}";
        interval = 1;
      };
      cpu = { format = " {}%"; };
      memory = { format = " {}%"; };
      modules-center = [ "clock" ];
      modules-left = [ "sway/workspaces" "sway/mode" "tray" ];
      modules-right = [ "temperature" "battery" ];
      pulseaudio = {
        format = "{icon} {volume}%";
        format-icons = [ "" "" ];
        format-muted = "";
      };
      "sway/workspaces" = {
        all-outputs = true;
        disable-scroll = true;
      };
      temperature = {
        critical-threshold = 90;
        format = "{icon} {temperatureC}°C";
        format-icons = [ "" "" "" "" "" ];
        hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
        interval = 1;
      };
    };
  };

  #services.pipewire = {
  #  enable = true;
  #  socketActivation = false;
  #};

  #systemd.user.services.pipewire.after = [ "xdg-desktop-portal.target" ];

  #systemd.user.services.xdg-desktop-portal = {
  #  wantedBy = [ "graphical-session.target" ];
  #  partOf = [ "graphical-session.target" ];
  #  after = [ "graphical-session-pre.target" ];
  #};
  #systemd.user.services.xdg-desktop-portal-gtk = {
  #  wantedBy = [ "graphical-session.target" ];
  #  partOf = [ "graphical-session.target" ];
  #  after = [ "graphical-session-pre.target" "xdg-desktop-portal.service" ];
  #};
  #systemd.user.services.xdg-desktop-portal-wlr = {
  #  wantedBy = [ "graphical-session.target" ];
  #  partOf = [ "graphical-session.target" ];
  #  after = [ "graphical-session-pre.target" "xdg-desktop-portal.service" ];
  #};

  #xdg.portal.enable = true;
  #xdg.portal.gtkUsePortal = true;
  #xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-wlr xdg-desktop-portal-gtk ];
}
