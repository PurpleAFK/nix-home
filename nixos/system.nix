# System-level extras that home-manager can't do. Not part of the flake:
# import it from /etc/nixos/configuration.nix
#   imports = [ ./hardware-configuration.nix /home/purpleafk/nix-home/nixos/system.nix ];
# then `sudo nixos-rebuild switch`.
{ pkgs, lib, ... }:

let
  # Not in nixpkgs and this system config isn't a flake, so pin a release.
  # Bump: nix-prefetch-url --unpack <tarball url>
  lanzaboote = import (builtins.fetchTarball {
    url = "https://github.com/nix-community/lanzaboote/archive/v1.2.0.tar.gz";
    sha256 = "0syvqpi77ia1vd189658g53mqjgw7i39zym2r0g7asdjkrz0mgmj";
  }) { };
in
{
  imports = [ lanzaboote.nixosModules.lanzaboote ];

  # --- lanzaboote (Secure Boot ready systemd-boot) ---------------------------
  # Replaces plain systemd-boot. Boots fine with Secure Boot off; keys are
  # generated into /var/lib/sbctl on activation but NOT enrolled. To turn
  # Secure Boot on later: put the firmware in Setup Mode, then
  # `sudo sbctl enroll-keys --microsoft` and enable it in the firmware.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    autoGenerateKeys.enable = true;
  };
  environment.systemPackages = [ pkgs.sbctl ];

  # --- zsh -------------------------------------------------------------------
  # ~/.zshrc runs compinit (after zinit adds fpath) and oh-my-posh sets the
  # prompt; the global ones just double startup time and fight over .zcompdump.
  programs.zsh.enableGlobalCompInit = false;
  programs.zsh.promptInit = "";

  # --- flatpak ---------------------------------------------------------------
  services.flatpak.enable = true;
  # Add flathub once at boot; install apps with `flatpak install flathub <id>`.
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # --- docker ----------------------------------------------------------------
  virtualisation.docker.enable = true;
  users.users.purpleafk.extraGroups = [ "docker" ];

  # --- GPU: AMD iGPU (05:00.0) + NVIDIA GTX 1650 Mobile (01:00.0) -------------
  # The iGPU drives the display; run things on the NVIDIA card with
  # `nvidia-offload <cmd>`.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = true; # Turing (GTX 16xx) supports the open kernel modules
    powerManagement = {
      enable = true;
      finegrained = true; # power the dGPU off when idle
    };
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      amdgpuBusId = "PCI:5:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
