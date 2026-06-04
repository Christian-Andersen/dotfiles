# dotfiles

## Stow

```sh
(mkdir -p ~/.config/fish && cd ~/dotfiles && stow --dotfiles home)
```

## Prerequisites

- Nix installed and the `nix-daemon` service running
- `stow` installed via your system package manager

```sh
# Clone
git clone https://github.com/christian/dotfiles ~/dotfiles && cd ~/dotfiles

# Stow configs (fish, etc.)
just stow

# First-time: build + activate without nh
just bootstrap

# Subsequent updates
just nix-activate

# Update flake lock + activate
just nix-update
```

## Dev Container

```sh
nix build ~/dotfiles/nix#christian && podman load < result

podman run --rm -it \
  -v ~/c:/root/c \
  dev
```
