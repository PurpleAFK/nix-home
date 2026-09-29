# nix-home

Home Manager (flake) version of the `~/dotfiles` stow repo. Nothing here has been activated yet.

## Layout
- `flake.nix`, `home.nix` – entry point (user `purpleafk`, `x86_64-linux`)
- `modules/packages.nix` – packages installed through nix
- `modules/files.nix` – replaces `stow`: symlinks `config/*` into `~`
- `modules/git.nix` – git identity
- `config/` – copy of every stow package from `~/dotfiles` (unchanged)

Links point **out of the store** to `~/nix-home/config`, so editing a config takes effect immediately without rebuilding. If you move this folder, update `repoDir` in `home.nix`.

## Install (NixOS)
1. In `/etc/nixos/configuration.nix` enable flakes and Hyprland (system level):
   ```nix
   nix.settings.experimental-features = [ "nix-command" "flakes" ];
   programs.hyprland.enable = true;
   programs.zsh.enable = true;
   users.users.purpleafk.shell = pkgs.zsh;
   security.pam.services.hyprlock = {};   # hyprlock can't unlock without this
   ```
   then `sudo nixos-rebuild switch`.
2. Clone the repo to `~/nix-home` (the path matters, see `repoDir` in `home.nix`):
   ```sh
   git clone https://github.com/PurpleAFK/nix-home.git ~/nix-home
   ```
3. First activation (home-manager isn't installed yet, so run it through `nix run`):
   ```sh
   nix run home-manager/master -- switch --flake ~/nix-home#purpleafk
   ```
   If it complains about existing files (e.g. an old `~/.zshrc`), move them away or add `-b backup`.
4. From then on, after changing any `.nix` file:
   ```sh
   home-manager switch --flake ~/nix-home#purpleafk
   ```
   Changes under `config/` apply immediately, no rebuild needed.
5. Update everything: `nix flake update --flake ~/nix-home` then switch again.
6. Log out and pick Hyprland in your display manager.

## TODO
- [ ] Fix polkit in `hypr/hyprland.conf`: it starts `/usr/lib/polkit-gnome/...`, which doesn't exist on NixOS.
      Use `${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1`, or
      `exec-once = systemctl --user start polkit-gnome-authentication-agent-1` if you enable it in NixOS.
- [ ] Install LSPs via `home.packages` instead of mason (its prebuilt binaries often fail on NixOS).
- [ ] Copy over what `.zshrc` sources from outside this repo (`~/cf-contests`, `~/cf/scripts`, fnm, opencode, spicetify).
- [ ] Copy your `~/.local/share/wallpapers` folder over (`config/wall/wallpapers` is kept but not linked).
- [ ] Move flatpaks, docker and GPU drivers into `configuration.nix`.
- [ ] Add niri
- [ ] Add GNOME

## Not managed here
- flatpaks (`system/flatpak-packages.txt` in the old dotfiles), docker, GPU drivers: those go in `configuration.nix` (see TODO)
- zsh plugins are still fetched by zinit at first shell start
- `config/helium/startpage.html` is copied but not linked anywhere
