# dotfiles

## Stow

```sh
(mkdir -p ~/.config/fish && cd ~/dotfiles && stow --dotfiles home)
```

## Nix (Home Manager)

```sh
nix build ~/dotfiles/nix#homeConfigurations.dev.activationPackage && ./result/activate
nix flake update ~/dotfiles/nix
```

## Dev Container

```sh
nix build ~/dotfiles/nix#christian && podman load < result

podman run --rm -it \
  -v ~/c:/root/c \
  dev
```
