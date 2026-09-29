# nix-home

Home Manager (flake) version of the `~/dotfiles` stow repo. Nothing here has been activated yet.

## Layout
- `flake.nix`, `home.nix` – entry point (user `purpleafk`, `x86_64-linux`)
- `modules/packages.nix` – packages installed through nix
- `modules/files.nix` – replaces `stow`: symlinks `config/*` into `~`
- `modules/git.nix` – git identity
- `config/` – copy of every stow package from `~/dotfiles` (unchanged)

Links point **out of the store** to `~/nix-home/config`, so editing a config takes effect immediately without rebuilding. If you move this folder, update `repoDir` in `home.nix`.

## Using it on NixOS
1. In `/etc/nixos/configuration.nix` enable flakes and Hyprland (system level):
   ```nix
   nix.settings.experimental-features = [ "nix-command" "flakes" ];
   programs.hyprland.enable = true;
   programs.zsh.enable = true;
   users.users.purpleafk.shell = pkgs.zsh;
   security.pam.services.hyprlock = {};   # hyprlock can't unlock without this
   ```
   then `sudo nixos-rebuild switch`.
2. Copy this folder to `~/nix-home` and run
   `nix run home-manager/master -- switch --flake ~/nix-home#purpleafk`
   (afterwards just `home-manager switch --flake ~/nix-home#purpleafk`).

## Things to fix after moving to NixOS
- `hypr/hyprland.conf` starts polkit from `/usr/lib/polkit-gnome/...`, which doesn't exist on NixOS.
  Use `${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1`, or just
  `exec-once = systemctl --user start polkit-gnome-authentication-agent-1` if you enable it in NixOS.
- nvim's mason downloads prebuilt LSP binaries, which often fail on NixOS; install LSPs via `home.packages` instead.
- `.zshrc` sources things outside this repo (`~/cf-contests`, `~/cf/scripts`, fnm, opencode, spicetify); copy those over too.
- Wallpapers: copy your `~/.local/share/wallpapers` folder over (it's not in this repo).

## Not managed here
- flatpaks (`system/flatpak-packages.txt` in the old dotfiles), docker, GPU drivers: those go in `configuration.nix`
- zsh plugins are still fetched by zinit at first shell start
- `config/helium/startpage.html` is copied but not linked anywhere
