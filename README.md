# Tools

# Using

Ripgrep
Fd
Bat
Zoxide

# Meh

Nushell

# Yet to Try

Fish
Eza
Xh
Zellij
Gitui
du-dust
dua
starship
yazi
hyperfine
evil-helix
bacon
cargo-info
fselect
ncspot
rusty-man
delta
ripgrep-all
tokei
wiki-tui
just
mask
mprocs
presenterm
kondo
bob-nvim
rtx
espanso


# Install Guide

## Update Debian/Ubuntu
```sh
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
sudo dpkg-reconfigure tzdata
```

## Install all dependencies
```sh
sudo apt install curl stow bat gcc unzip luarocks ripgrep npm fd-find xclip fzf python3-venv python3-pip -y
mkdir -p ~/.local/bin
ln -s $(which batcat) ~/.local/bin/bat
ln -s $(which fdfind) ~/.local/bin/fd
```

## Recursively Clone this Repo
Create an SSH key and add it do your [GitHub SSH keys](https://github.com/settings/ssh/new).
```sh
ssh-keygen -t ed25519 -C "@gmail.com"
cat ~/.ssh/id_ed25519.pub
```
```sh
git clone --recursive git@github.com:Christian-Andersen/dotfiles.git
```
Else just clone it.
```sh
git clone --recursive https://github.com/Christian-Andersen/dotfiles.git
```

## Install zsh and oh-my-zsh
```sh
sudo apt install zsh -y
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

## Stow
Run first `rm ~/.zshrc` first for stow to work.
```sh
cd ~/dotfiles && stow --no-folding .; cd ~
```

## Install UV
```sh
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.zshrc
```

## Install Neovim
[Grab the .deb package](https://github.com/neovim/neovim-releases/releases/latest)
```sh
wget https://github.com/neovim/neovim-releases/releases/latest/download/nvim-linux-x86_64.deb
sudo dpkg -i nvim-linux-x86_64.deb
rm nvim-linux-x86_64.deb
sudo apt install python3-pynvim -y
```
