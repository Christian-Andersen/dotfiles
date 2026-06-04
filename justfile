[private]
default:
    just --choose

stow:
    mkdir -p ~/.config/fish && stow --dotfiles home

[working-directory('nix')]
nix-activate:
    nh home switch .

[working-directory('nix')]
nix-update:
    nh home switch -u .

[working-directory('nix')]
container-build:
    nix build '.#christian' && podman load < result

container-run:
    podman run --rm -it -v ~/c:/root/c dev

[working-directory('nix')]
vulnix-flake:
    nix build '.#christian' && vulnix ./result
