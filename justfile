[private]
default:
    @just --list

stow:
    mkdir -p ~/.config/fish && stow --dotfiles -t "$HOME" home
