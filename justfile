[private]
default:
    just --choose

stow:
    mkdir -p ~/.config/fish && stow --dotfiles home

[working-directory('nix')]
nix-activate:
    nix build '.#homeConfigurations.dev.activationPackage' && ./result/activate

[working-directory('nix')]
nix-update:
    nix flake update

[working-directory('nix')]
container-build:
    nix build '.#dev' && podman load < result

container-run:
    podman run --rm -it -v ~/c:/root/c dev

[working-directory('nix')]
vulnix-flake:
    nix build '.#dev' && vulnix ./result
