{
  description = "PurpleAFK's Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Neither browser is in nixpkgs; these are community flakes.
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    helium = {
      url = "github:schembriaiden/helium-browser-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, zen-browser, helium, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        # discord, sublime4
        config.allowUnfree = true;
        overlays = [
          helium.overlays.default
          (final: prev: {
            zen-browser = zen-browser.packages.${system}.beta;

            # nixpkgs' sublime4 is stuck on build 4200, which it marks broken
            # (plugin host needs EOL openssl). Builds >= 4205 ship a working
            # plugin host, so reuse nixpkgs' recipe with a newer build.
            # Bump: version from https://download.sublimetext.com/latest/stable,
            # hash = base64 sha256 of the tarball.
            sublime4 = final.callPackage
              (import "${nixpkgs}/pkgs/applications/editors/sublime/4/common.nix" {
                buildVersion = "4215";
                x64sha256 = "wVP0GNOrJrkOzOjAKoLk6WECXtemX34lBgpUV9Q+iNk=";
                aarch64sha256 = "0xRmWkJy8zVRUDQyNyo0UW27WpoS3OKkcELBlC9m7nk=";
              }) { };
          })
        ];
      };
    in {
      homeConfigurations."purpleafk" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };
    };
}
