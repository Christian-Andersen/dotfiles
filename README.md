# Install Guide

## Update Debian/Ubuntu
```
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
```

## Install all dependencies
```
sudo apt install curl stow bat gcc unzip luarocks ripgrep npm python3-venv python3-pip fd-find python3-pynvim xclip fzf -y
mkdir -p ~/.local/bin
ln -s $(which batcat) ~/.local/bin/bat
ln -s $(which fdfind) ~/.local/bin/fd
```

## Recursively Clone this Repo
Create an SSH key and add it do your [GitHub SSH keys](https://github.com/settings/ssh/new).
```
ssh-keygen -t ed25519 -C "@gmail.com"
cat ~/.ssh/id_ed25519.pub
```
```
git clone --recursive git@github.com:Christian-Andersen/dotfiles.git
```
Else just clone it.
```
git clone --recursive https://github.com/Christian-Andersen/dotfiles.git
```

## Install zsh
```
sudo apt install zsh -y
chsh -s $(which zsh)
```
Now reload your shell.

## Install oh-my-zsh
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## Stow
You may need to remove ~/.zshrc first. This needs the directories to be made first.
```
mkdir -p ~/.config/nvim
cd dotfiles && stow . && cd ~
```

## Install UV
```
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.zshrc
```

## Install Neovim
[Grab the .deb package](https://github.com/neovim/neovim-releases/releases/latest)
```
wget https://github.com/neovim/neovim-releases/releases/latest/download/nvim-linux-x86_64.deb
sudo dpkg -i nvim-linux-x86_64.deb
rm nvim-linux-x86_64.deb
```
