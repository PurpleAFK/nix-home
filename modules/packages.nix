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

    # LSPs + formatters for nvim (instead of mason, whose binaries don't run on NixOS)
    lua-language-server
    clang-tools                    # clangd
    pyright
    texlab
    vscode-langservers-extracted   # html, cssls
    tailwindcss-language-server
    prisma-language-server
    prettier
    stylua
    isort
    black

    # things .zshrc used to pull from outside the repo
    fnm
    opencode
    spicetify-cli

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
