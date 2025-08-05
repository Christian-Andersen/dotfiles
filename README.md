# Tools

## Yes

[Zellij](https://github.com/zellij-org/zellij)

[Fish](https://github.com/fish-shell/fish-shell)

[starship](https://github.com/starship/starship)

[Ripgrep](https://github.com/BurntSushi/ripgrep)

[Fd](https://github.com/sharkdp/fd)

[Bat](https://github.com/sharkdp/bat)

[Zoxide](https://github.com/ajeetdsouza/zoxide)

[Eza](https://github.com/eza-community/eza)

[lazygit](https://github.com/jesseduffield/lazygit)

# Niche

[du-dust](https://github.com/bootandy/dust?tab=readme-ov-file)

[dua](https://github.com/Byron/dua-cli)

[hyperfine](https://github.com/sharkdp/hyperfine)

[tokei](https://github.com/XAMPPRocky/tokei)

## Broken

[yazi](https://github.com/sxyazi/yazi)

[Gitui](https://github.com/gitui-org/gitui)

# Install Guide

## Install all dependencies
```sh
sudo pacman -Syu --noconfirm neovim uv man curl stow bat gcc unzip luarocks ripgrep npm fd xclip fzf python-pip python-pynvim
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
