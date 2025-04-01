# Prerequisites

## Update Debian/Ubuntu
```
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
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

## Install Neovim
[Grab the .deb package](https://github.com/neovim/neovim-releases/releases/latest)
```
wget https://github.com/neovim/neovim-releases/releases/latest/download/nvim-linux-x86_64.deb
sudo dpkg -i nvim-linux-x86_64.deb
rm nvim-linux-x86_64.deb
```

## Install UV
```
curl -LsSf https://astral.sh/uv/install.sh | sh
```
