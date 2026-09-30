{ config, ... }:

{
  imports = [
    ./modules/packages.nix
    ./modules/files.nix
    ./modules/git.nix
    ./modules/services.nix
  ];

  home.username = "purpleafk";
  home.homeDirectory = "/home/purpleafk";

  # Where this repo lives on disk. Config files are symlinked *out of the
  # store* into <repoDir>/config, so edits apply instantly (no rebuild) and
  # programs that write into their own config (nvim's lazy-lock.json, ...)
  # keep working. Change this if you move the folder.
  _module.args.repoDir = "${config.home.homeDirectory}/nix-home";

  # Install GUI apps (kitty, hyprlock, easyeffects, ...) from nixpkgs.
  # Fine on NixOS; set to false if you ever use this on a non-NixOS distro.
  _module.args.installGui = true;

  home.sessionVariables.EDITOR = "nvim";

  fonts.fontconfig.enable = true;

  programs.home-manager.enable = true;

  # Don't change after first activation.
  home.stateVersion = "25.05";
}
