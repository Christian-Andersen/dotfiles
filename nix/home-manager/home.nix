# Shared home-manager module, used two ways:
#   - standalone on non-NixOS machines (Arch/Ubuntu): `nh home switch .`
#   - on NixOS, as a module of nixosConfigurations.nixos
# Packages only — file management stays with stow so the same dotfiles tree
# works everywhere, including the dev-container image (which has no
# home-manager). See ../image.nix.
{pkgs, ...}: let
  symlinks = import ../symlinks.nix {inherit pkgs;};
in {
  programs.bash.enable = false;

  home.username = "christian";
  home.homeDirectory = "/home/christian";

  home.packages = (import ../tools.nix {inherit pkgs;}) ++ [symlinks];

  home.stateVersion = "24.11";
}
