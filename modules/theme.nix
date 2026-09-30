{ pkgs, ... }:

{
  # Old Ubuntu cursor (pre-Yaru). gtk.enable wires it into GTK settings.ini + dconf;
  # hyprland.conf sets XCURSOR_* for the compositor itself.
  home.pointerCursor = {
    enable = true;
    package = pkgs.vanilla-dmz;
    name = "DMZ-Black";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    font = {
      package = pkgs.iosevka;
      name = "Iosevka";
      size = 11;
    };
  };
}
