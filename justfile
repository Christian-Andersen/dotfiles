[private]
default:
    just --list

stow:
    mkdir -p ~/.config/fish && stow --dotfiles home

run:
    podman run --rm -it -v ~/c:/root/c dev

nix-setup:
    nix build '.#homeConfigurations.christian.activationPackage'
    ./result/activate

nix-activate:
    nh home switch .

nix-update:
    nh home switch -u .

nix-build:
    nix build
    podman load < result

nix-vul:
    nix build
    vulnix ./result
