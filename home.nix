{ config, ... }:

{
  imports = [
    ./modules/packages.nix
    ./modules/files.nix
    ./modules/git.nix
  ];

  home.username = "purpleafk";
  home.homeDirectory = "/home/purpleafk";

  # Where this repo lives on disk. Config files are symlinked *out of the
  # store* into <repoDir>/config, so edits apply instantly (no rebuild) and
  # programs that write into their own config (nvim's lazy-lock.json, ...)
  # keep working. Change this if you move the folder.
  _module.args.repoDir = "${config.home.homeDirectory}/nix-home";

  # Set to true to also install GL-dependent GUI apps (kitty) from nixpkgs.
  # On non-NixOS distros (you're on Fedora) these usually need nixGL, so the
  # default is to keep using the distro's package.
  _module.args.installGui = false;

  home.sessionVariables.EDITOR = "nvim";

  fonts.fontconfig.enable = true;

  programs.home-manager.enable = true;

  # Don't change after first activation.
  home.stateVersion = "25.05";
}
