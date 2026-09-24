[private]
default:
    just --list

stow:
    mkdir -p ~/.config/fish && stow --dotfiles home

run:
    podman run --rm -it -v ~/c:/root/c dev

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
