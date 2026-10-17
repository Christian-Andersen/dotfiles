# dotfiles

## Stow

```sh
(mkdir -p ~/.config/fish && cd ~/dotfiles && stow --dotfiles home)
```

```sh
# Clone
git clone https://github.com/christian/dotfiles ~/dotfiles && cd ~/dotfiles

# Stow configs (fish, etc.)
just stow
```

## NixOS machines

The system config lives in `nix/os/nixos` inside the same flake:
rebuild with

```sh
just os
just os-update   # update flake.lock + rebuild
```

(or `nh os switch` — the default flake is set via `NH_FLAKE`).
`./nix/os/nixos/hardware-configuration.nix` is machine-specific; keep
one `os/<hostname>/` directory per machine.

## Non-NixOS machines (Arch/Ubuntu)

```sh
# First-time: build + activate without nh
just nix-setup

# Subsequent updates
just nix-activate

# Update flake lock + activate
just nix-update
```

## Dev Container

```sh
nix build ~/dotfiles/nix#christian --out-link /tmp/dotfiles-image && podman load < /tmp/dotfiles-image

podman run --rm -it \
  -v ~/c:/root/c \
  dev
```
