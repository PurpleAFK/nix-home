# nix-home

Home Manager (flake) version of the old `~/dotfiles` stow repo, running on NixOS.

## Layout
- `flake.nix`, `home.nix` – entry point (user `purpleafk`, `x86_64-linux`)
- `modules/packages.nix` – packages installed through nix (incl. nvim's LSPs/formatters)
- `modules/files.nix` – replaces `stow`: symlinks `config/*` into `~`
- `modules/services.nix` – user services (polkit agent for Hyprland)
- `modules/git.nix` – git identity
- `nixos/system.nix` – system-level extras (flatpak, docker, NVIDIA PRIME); imported from `/etc/nixos/configuration.nix`, not part of the flake
- `config/` – every stow package from the old dotfiles

Links point **out of the store** to `~/nix-home/config`, so editing a config takes effect immediately without rebuilding. If you move this folder, update `repoDir` in `home.nix` and the import path in `configuration.nix`.

## Install (NixOS)
1. In `/etc/nixos/configuration.nix` enable flakes and Hyprland (system level) and import `nixos/system.nix`:
   ```nix
   imports = [ ./hardware-configuration.nix /home/purpleafk/nix-home/nixos/system.nix ];

   nix.settings.experimental-features = [ "nix-command" "flakes" ];
   programs.hyprland.enable = true;
   programs.zsh.enable = true;
   users.users.purpleafk.shell = pkgs.zsh;
   security.pam.services.hyprlock = {};   # hyprlock can't unlock without this
   ```
   `nixos/system.nix` has the GPU bus IDs of this laptop (`lspci | grep -E 'VGA|3D'`); change them on other hardware.
   Then `sudo nixos-rebuild switch`.
2. Clone the repo to `~/nix-home` (the path matters, see `repoDir` in `home.nix`):
   ```sh
   git clone https://github.com/PurpleAFK/nix-home.git ~/nix-home
   ```
3. First activation (home-manager isn't installed yet, so run it through `nix run`):
   ```sh
   nix run home-manager/master -- switch -b backup --flake ~/nix-home#purpleafk
   ```
   `-b backup` renames files that are in the way (e.g. an old `~/.zshrc`) to `*.backup`.
4. From then on, after changing any `.nix` file:
   ```sh
   home-manager switch --flake ~/nix-home#purpleafk
   ```
   Changes under `config/` apply immediately, no rebuild needed.
5. Update everything: `nix flake update --flake ~/nix-home` then switch again.
6. Log out and pick Hyprland in your display manager.

## Notes
- **LSPs** come from nix (`modules/packages.nix`), not mason; mason was removed because its prebuilt binaries don't run on NixOS. To add a server: add the package, then add its name to `vim.lsp.enable` in `nvim/.../plugins/lsp/lspconfig.lua`. Run `:Lazy clean` once to drop the old mason plugins.
- **GPU**: the AMD iGPU drives the display; run something on the NVIDIA card with `nvidia-offload <cmd>`.
- **Flatpak**: flathub is added automatically; the old app list is gone, so reinstall with `flatpak install flathub <id>`.
- **Docker**: your user is in the `docker` group (log out and back in after the first rebuild).
- **Wallpapers**: `~/.local/share/wallpapers` links to `config/wall/wallpapers`.

## TODO
- [ ] Add niri
- [ ] Add GNOME

## Not managed here
- `~/cf` and `~/cf-contests` (competitive programming scripts `.zshrc` sources if present): restore them from a backup
- zsh plugins are still fetched by zinit at first shell start
- `config/helium/startpage.html` is copied but not linked anywhere
