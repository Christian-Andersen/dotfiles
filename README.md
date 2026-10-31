# dotfiles

    # Fresh Arch install + dotfiles. Run with: bash README.md
    set -euo pipefail
    cd "$(dirname "$0")"
    sudo pacman --needed --noconfirm -Syyu \
        base \
        base-devel \
        bat \
        btop \
        cargo-audit \
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
        rustup \
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
    rustup set profile minimal
    rustup default stable
    rustup component add rust-src clippy rustfmt
    mkdir -p ~/.config/fish
    stow --dotfiles --target "$HOME" home
