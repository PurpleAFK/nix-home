{ pkgs, installGui, lib, ... }:

{
  home.packages = with pkgs; [
    # shell / cli (used by .zshrc)
    zsh
    oh-my-posh
    zoxide
    fzf
    fd
    bat
    eza
    ripgrep
    jq
    curl
    tmux
    tmuxifier
    yazi
    fastfetch
    cava
    btop
    gh

    # neovim + what its plugins (treesitter, mason, telescope) shell out to
    neovim
    gcc
    gnumake
    unzip
    nodejs
    tree-sitter

    # theming
    pywal
    imagemagick   # pywal's palette backend + rofi wallpaper-picker thumbnails
    wallust
    matugen

    # wayland / hyprland helpers (hyprland itself: enable it in configuration.nix)
    waybar
    rofi
    swaynotificationcenter
    awww
    cliphist
    wl-clipboard
    grim
    slurp
    libnotify
    brightnessctl
    playerctl
    picom
    kanata

    # fonts
    nerd-fonts.jetbrains-mono
    jetbrains-mono
    fira-code
    font-awesome
    comfortaa

    # cli
    claude-code
  ] ++ lib.optionals installGui [
    kitty
    hyprlock
    hyprshot
    easyeffects
    polkit_gnome
    pavucontrol

    # apps (zen-browser, helium, sublime4 come from overlays in flake.nix)
    helium
    zen-browser
    discord
    sublime4
    zotero
    anki
    foliate
  ];
}
