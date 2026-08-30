[private]
default:
    just --list

stow:
    mkdir -p ~/.config/fish && stow --dotfiles home

run:
    podman run --rm -it -v ~/c:/root/c dev

[working-directory('nix')]
nix-setup:
    nix build '.#homeConfigurations.christian.activationPackage'
    ./result/activate

[working-directory('nix')]
nix-activate:
    nh home switch .

[working-directory('nix')]
nix-update:
    nh home switch -u .

[working-directory('nix')]
nix-build:
    nix build
    podman load < result

[working-directory('nix')]
nix-vul:
    nix build
    vulnix ./result
