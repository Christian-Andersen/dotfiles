{
  description = "Christian's development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dotfiles-root = {
      url = "path:../";
      flake = false;
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    dotfiles-root,
    self,
    ...
  }: let
    system = "x86_64-linux";
    nixpkgs-settings = import ./nixpkgs.nix;
    pkgs = import nixpkgs {
      inherit system;
      config = nixpkgs-settings.config;
      overlays = nixpkgs-settings.overlays;
    };
    tools = import ./tools.nix {inherit pkgs;};
    home-module = import ./home-manager/home.nix;
  in {
    formatter.${system} = pkgs.alejandra;

    # Standalone home-manager, used on non-NixOS machines (Arch/Ubuntu):
    #   nh home switch .
    homeConfigurations.christian = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [home-module];
    };

    # The NixOS system (home machine; hostname "nixos"): rebind with
    #   sudo nixos-rebuild switch --flake ~/dotfiles/nix#nixos
    # (or `nh os switch ~/dotfiles/nix`).
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./os/nixos/default.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.christian.imports = [home-module];
        }
      ];
    };

    packages.${system} = {
      christian = import ./image.nix {
        inherit pkgs tools;
        dotfilesSrc = dotfiles-root;
      };
      default = self.packages.${system}.christian;
    };
  };
}
