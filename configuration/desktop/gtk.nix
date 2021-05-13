{ config, pkgs, ... }:

{
  services.dbus.packages = with pkgs; [ gnome3.dconf ];
  home-manager.users.fluepke = {
    gtk = {
      enable = true;
      font.name = "Bitstream Vera Sans";
      font.size = 12;
      theme = {
        package = pkgs.gnome3.gnome_themes_standard; 
        name = "Adwaita";
      };
    };
    qt = {
      enable = true;
      style = {
        package = pkgs.adwaita-qt;
        name = "adwaita-dark";
      };
    };
  };
}
