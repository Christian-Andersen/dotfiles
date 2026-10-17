[private]
default:
    just --list

stow:
    mkdir -p ~/.config/fish && stow --dotfiles -t "$HOME" home

# NixOS machines: rebuild the system from the flake
[working-directory('nix')]
os:
    nh os switch .

[working-directory('nix')]
os-update:
    nh os switch -u .

run image="ghcr.io/christian-andersen/dotfiles:latest":
    podman run --rm -it -v ${XDG_PROJECTS_DIR:-$HOME/Projects}:/root/Projects {{image}}

# Non-NixOS machines (Arch/Ubuntu): standalone home-manager
[working-directory('nix')]
nix-setup:
    nix build --out-link /tmp/dotfiles-activation '.#homeConfigurations.christian.activationPackage'
    /tmp/dotfiles-activation/activate

[working-directory('nix')]
nix-activate:
    nh home switch .

[working-directory('nix')]
nix-update:
    nh home switch -u .

[working-directory('nix')]
nix-build:
    nix build --out-link /tmp/dotfiles-image
    podman load < /tmp/dotfiles-image
