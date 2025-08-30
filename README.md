# Install Guide

## Install all dependencies
```sh
curl git stow
```

## Clone this Repo
Create an SSH key and add it do your [GitHub SSH keys](https://github.com/settings/ssh/new).
```sh
ssh-keygen -t ed25519 -C "@gmail.com"
cat ~/.ssh/id_ed25519.pub
...
git clone --recursive git@github.com:Christian-Andersen/dotfiles.git
```
Else just clone it.
```sh
git clone --recursive https://github.com/Christian-Andersen/dotfiles.git
```

## Stow
```sh
cd ~/dotfiles && stow --no-folding .; cd ~
```

## Brew
```sh
/home/linuxbrew/.linuxbrew/bin/brew bundle --global
echo /home/linuxbrew/.linuxbrew/bin/fish | sudo tee --append /etc/shells
chsh -s /home/linuxbrew/.linuxbrew/bin/fish
```
