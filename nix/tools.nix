# User-level CLI tools and apps, shared by the standalone home-manager env
# (Arch/Ubuntu), the NixOS system's home-manager user, and the dev-container
# image (image.nix). System-only packages stay in os/nixos/default.nix.
{pkgs}: let
  huggingface-hub = pkgs.python3Packages.huggingface-hub;
in
  with pkgs; [
    _7zz
    alejandra
    antigravity-cli
    aria2
    bash
    bash-language-server
    bat
    bat-extras.batdiff
    bat-extras.batgrep
    bat-extras.batman
    bat-extras.batpipe
    bat-extras.batwatch
    bat-extras.prettybat
    biome
    brightnessctl
    buf
    cargo
    chafa
    chromium
    clang-tools
    clippy
    cmake-language-server
    curl
    dash
    deadnix
    delve
    deno
    direnv
    dockerfile-language-server
    dos2unix
    dotenv-linter
    dust
    emmet-language-server
    entr
    eslint_d
    eza
    fastfetch
    fd
    fish
    fish-lsp
    fnm
    fzf
    gcc
    gh
    ghostty
    git
    git-lfs
    git-xet
    gnutar
    go
    golangci-lint
    grim
    gopls
    gzip
    huggingface-hub
    hyperfine
    jj
    jq
    just
    just-lsp
    lazydocker
    lazygit
    libnotify
    lldb
    lua-language-server
    markdownlint-cli
    marksman
    mermaid-cli
    mesonlsp
    neovim
    nh
    ninja
    nix-direnv
    nixd
    nodejs
    noctalia
    opencode
    openssh
    openssl
    parallel
    pi-coding-agent
    podman-compose
    prek
    prettier
    pulseaudio
    (python3.withPackages (ps: [ps.pyyaml]))
    # Extra interpreters for uv on NixOS, where UV_PYTHON_DOWNLOADS is off
    # (downloaded CPython builds are dynamically linked and won't run).
    # python3 is already 3.14, so only 3.15 is added as a normal build at an
    # intermediate priority: above the python3 env it must never share names
    # with (bin/python3, bin/idle), below the free-threaded build it must
    # beat for the 3.15-specific files they both ship.
    (lib.meta.setPrio 7 python315)
    # Free-threaded ("t", GIL-less) builds. They also ship the normal
    # interpreter and files idle/pydoc, which collide with their sibling and
    # python315 (above) sits at priority 7: the python3 env (5) keeps the
    # shared unversioned names (bin/python3, bin/idle), python315 keeps the
    # 3.15-specific ones, and these flaky builds (lowPrio == setPrio 10) lose
    # on all duplicated files while still exposing python3.14t/3.15t.
    (lib.lowPrio (python314.override {enableGIL = false;}))
    (lib.lowPrio (python315.override {enableGIL = false;}))
    resvg
    ripgrep
    rsync
    ruff
    rust-analyzer
    rustc
    rustfmt
    shellcheck
    shfmt
    slurp
    spotify-player
    sql-formatter
    sqlite
    starship
    statix
    stow
    stylua
    swaybg
    swayidle
    taplo
    tea
    tectonic
    tlrc
    tokei
    tree-sitter
    tuxedo
    ty
    unar
    unzip
    uv
    vscode-css-languageserver
    vscode-json-languageserver
    vtsls
    vue-language-server
    watchexec
    wget
    wl-clipboard
    xdg-utils
    yaml-language-server
    yamlfmt
    yazi
    yq-go
    zellij
    zig
    zls
    zoxide
  ]
