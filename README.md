# nix-home

Home Manager (flake) version of the `~/dotfiles` stow repo. Nothing here has been activated yet.

## Layout
- `flake.nix`, `home.nix` – entry point (user `purpleafk`, `x86_64-linux`)
- `modules/packages.nix` – packages installed through nix
- `modules/files.nix` – replaces `stow`: symlinks `config/*` into `~`
- `modules/git.nix` – git identity
- `config/` – copy of every stow package from `~/dotfiles` (unchanged)

Links point **out of the store** to `~/nix-home/config`, so editing a config takes effect immediately without rebuilding. If you move this folder, update `repoDir` in `home.nix`.

## First-time setup (Fedora)
1. Install Nix (with flakes): `curl -L https://nixos.org/nix/install | sh -s -- --daemon`, then add
   `experimental-features = nix-command flakes` to `/etc/nix/nix.conf`.
2. Move the existing files out of the way (Home Manager refuses to overwrite them), or run stow's `-D` first: `cd ~/dotfiles && stow -D */`.
   Also back up `~/.zshrc`, `~/.tmux.conf`.
3. Flakes only see git-tracked files: `cd ~/nix-home && git init && git add -A`.
4. `nix run home-manager/master -- switch --flake ~/nix-home#purpleafk -b backup`
   afterwards: `home-manager switch --flake ~/nix-home#purpleafk`

## Not handled by nix (keep using the distro)
- `hyprland`, `hyprlock`, `hyprshot`, GPU drivers, `easyeffects`, `polkit-gnome` (config is linked, packages are not; Hyprland from nix needs nixGL on Fedora)
- `kitty` (set `installGui = true` in `home.nix` to install it from nix anyway)
- `waywall`, `helium`, docker, flatpaks, `system/*.txt` package lists
- zsh plugins are still fetched by zinit at first shell start (as before)
- `config/helium/startpage.html` is copied but not linked anywhere
