mod nix

[private]
default:
    just --list

stow:
    mkdir -p ~/.config/fish && stow --dotfiles home

run:
    podman run --rm -it -v ~/c:/root/c dev
