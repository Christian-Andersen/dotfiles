# Install Guide

## Dependencies
```sh
build-essential procps curl file git stow uidmap
```

## Clone this Repo
Create an SSH key and add it do your [GitHub SSH keys](https://github.com/settings/ssh).
```sh
ssh-keygen -t ed25519 -C "your-email@example.com"
cat ~/.ssh/id_ed25519.pub
...
git clone git@github.com:Christian-Andersen/dotfiles.git
```
Else clone with HTTPS:
```sh
git clone https://github.com/Christian-Andersen/dotfiles.git
```

## Stow
```sh
(cd ~/dotfiles && stow --dotfiles home)
```

