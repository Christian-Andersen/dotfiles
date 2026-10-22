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

  # Default flake for `nh`: the NixOS system on NixOS machines,
  # homeConfigurations.christian elsewhere. Fish sets this in its stowed
  # config too, because home-manager session vars aren't sourced by fish.
  home.sessionVariables.NH_FLAKE = "/home/christian/dotfiles/nix";

  # XDG Projects directory (xdg-user-dirs 0.20+): one flat checkout per
  # repo (<repo>), consumed by the fish config.
  home.sessionVariables.XDG_PROJECTS_DIR = "$HOME/c";

  home.stateVersion = "24.11";
}
