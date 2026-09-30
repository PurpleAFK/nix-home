# System-level extras that home-manager can't do. Not part of the flake:
# import it from /etc/nixos/configuration.nix
#   imports = [ ./hardware-configuration.nix /home/purpleafk/nix-home/nixos/system.nix ];
# then `sudo nixos-rebuild switch`.
{ pkgs, ... }:

{
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
