FROM archlinux

RUN pacman -Syu --noconfirm --needed \
  base base-devel git curl wget openssh parallel stow sshpass sudo \
  fzf eza bat fd ripgrep jq 7zip gzip unzip tar xz \
  gcc ninja cmake go python python-pip nodejs npm \
  fish zellij starship zoxide lazygit yazi hyperfine dust tokei tldr fastfetch chafa \
  openssl dos2unix aria2 shellcheck uv neovim \
  && pacman -Scc --noconfirm

ENV SHELL=/usr/bin/fish
RUN usermod -s /usr/bin/fish root

COPY . /root/dotfiles
RUN cd /root/dotfiles && stow --dotfiles home

RUN nvim --headless -c "lua vim.pack.update()" -c "qa"
RUN nvim --headless -c "MasonToolsInstallSync" -c "qa"

WORKDIR /root
CMD ["/usr/bin/fish"]
