{ pkgs, ... }:

let
  p = pkgs.tmuxPlugins;
in
{
  # tmux plugins come from nixpkgs instead of TPM (no runtime git clones).
  # ~/.tmux.conf (linked from config/tmux) sources this file; plugin *options*
  # stay in .tmux.conf and must be set before the source line.
  # Order matters: continuum hooks into status-right, so it loads after the theme.
  xdg.configFile."tmux/plugins.conf".text = ''
    run-shell ${p.sensible.rtp}
    run-shell ${p.vim-tmux-navigator.rtp}
    run-shell ${p.resurrect.rtp}
    run-shell ${p.ukiyo.rtp}
    run-shell ${p.continuum.rtp}
  '';
}
