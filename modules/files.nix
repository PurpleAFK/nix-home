{ config, repoDir, ... }:

let
  # Live symlink into this repo's config/ folder (not copied to the store).
  link = path: config.lib.file.mkOutOfStoreSymlink "${repoDir}/config/${path}";
in
{
  # Equivalent of `stow <pkg>` for every package in the old dotfiles repo.
  xdg.configFile = {
    "cava".source        = link "cava/.config/cava";
    "fastfetch".source   = link "fastfetch/.config/fastfetch";
    "hypr".source        = link "hypr/.config/hypr";
    "kanata".source      = link "kanata/.config/kanata";
    "kitty".source       = link "kitty/.config/kitty";
    "nvim".source        = link "nvim/.config/nvim";
    "ohmyposh".source    = link "ohmyposh/.config/ohmyposh";
    "picom".source       = link "picom/.config/picom";
    "rofi".source        = link "rofi/.config/rofi";
    "scripts".source     = link "scripts/.config/scripts";
    "swaync".source      = link "swaync/.config/swaync";
    "waybar".source      = link "waybar/.config/waybar";
    "waywall".source     = link "waywall/.config/waywall";
    "xkb".source         = link "xkb/.config/xkb";
    "yazi".source        = link "yazi/.config/yazi";
    # pywal writes elsewhere under ~/.config/wal, so only link the templates
    "wal/templates".source = link "wal/.config/wal/templates";
  };

  home.file = {
    ".zshrc".source          = link "zsh/.zshrc";
    ".tmux.conf".source      = link "tmux/.tmux.conf";
    "tmuxifier.tmux".source  = link "tmux/tmuxifier.tmux";

    # ~/bin -> scripts (same as stow did; .zshrc's convergence aliases use ~/bin)
    "bin".source = link "bin/bin";

    # config/wall/wallpapers is kept but NOT linked: ~/.local/share/wallpapers
    # is a real folder with your own collection.
  };
}
