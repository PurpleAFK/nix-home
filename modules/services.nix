{ lib, ... }:

{
  # polkit agent for Hyprland. Not tied to graphical-session.target, so it
  # doesn't fight GNOME's built-in agent; hyprland.conf starts it with
  # `systemctl --user start polkit-gnome`.
  services.polkit-gnome.enable = true;
  systemd.user.services.polkit-gnome.Install = lib.mkForce { };
}
