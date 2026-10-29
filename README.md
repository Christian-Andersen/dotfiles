# dotfiles

```sh
sudo pacman --needed --noconfirm -Syyu \
base \
base-devel \
bat \
btop \
chromium \
eza \
fd \
fish \
fzf \
ghostscript \
git \
go \
hyperfine \
imagemagick \
just \
lazydocker \
lazygit \
lldb \
luarocks \
man-db \
mermaid-cli \
neovim \
npm \
parallel \
pnpm \
prek \
python-pip \
ripgrep \
rust \
starship \
stow \
sudo \
tectonic \
tldr \
tree-sitter-cli \
unzip \
uv \
wget \
wl-clipboard \
xdg-utils \
yazi \
zellij \
zig \
zoxide
mkdir -p ~/.config/fish
stow --dotfiles --target "$HOME" home
```
