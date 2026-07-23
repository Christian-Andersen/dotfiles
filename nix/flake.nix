{
  description = "Christian's development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dotfiles-root = {
      url = "path:../";
      flake = false;
    };
  };

  outputs = { nixpkgs, home-manager, dotfiles-root, ... }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "pnpm-10.34.0"
        ];
      };
    };
    huggingface-hub = pkgs.python3Packages.huggingface-hub;
    debugpy = pkgs.python3Packages.debugpy;
    tools = with pkgs; [
      _7zz
      alejandra
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
      buf
      chafa
      cmake-language-server
      clang-tools
      curl
      dash
      deadnix
      debugpy
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
      git
      git-lfs
      git-xet
      go
      golangci-lint
      gopls
      harlequin
      huggingface-hub
      hyperfine
      jj
      jq
      just
      just-lsp
      lazygit
      lazydocker
      lldb
      lua-language-server
      markdownlint-cli
      marksman
      mesonlsp
      neovim
      nh
      nix-direnv
      nixd
      nixpkgs-fmt
      nodejs
      ninja
      opencode
      parallel
      pi-coding-agent
      prek
      prettier
      resvg
      ripgrep
      rsync
      (pkgs.lib.lowPrio pkgs.rustup)
      pkgs.rust-analyzer
      ruff
      shellcheck
      shfmt
      sql-formatter
      starship
      statix
      stow
      stylua
      tlrc
      taplo
      tokei
      tuxedo
      ty
      unar
      unzip
      uv
      vscode-css-languageserver
      vscode-json-languageserver
      vtsls
      vue-language-server
      vulnix
      watchexec
      wget
      wl-clipboard
      xdg-utils
      yaml-language-server
      yazi
      yq
      yamlfmt
      zellij
      zig
      zls
      zoxide
    ];
  in {
    homeConfigurations = {
      christian = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ 
          ./home.nix
        ];
        extraSpecialArgs = { inherit tools; };
      };
    };
    packages.${system} = {
      christian = import ./image.nix { inherit pkgs tools; dotfilesSrc = dotfiles-root; };
    };
  };
}
