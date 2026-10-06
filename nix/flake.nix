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

  outputs = {
    nixpkgs,
    home-manager,
    dotfiles-root,
    self,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
      # TODO: remove once nixpkgs fixes sqlfmt's pname upstream
      overlays = [
        (_: prev: {
          pythonPackagesExtensions =
            (prev.pythonPackagesExtensions or [])
            ++ [
              (_: pyprev: {
                sqlfmt = pyprev.sqlfmt.overridePythonAttrs (_: {
                  pname = "shandy-sqlfmt";
                });
              })
            ];
        })
      ];
    };
    huggingface-hub = pkgs.python3Packages.huggingface-hub;
    tools = with pkgs; [
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
      buf
      chafa
      clang-tools
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
      git
      git-lfs
      git-xet
      gnutar
      go
      golangci-lint
      gopls
      gzip
      harlequin
      huggingface-hub
      hyperfine
      jj
      jq
      just
      just-lsp
      lazydocker
      lazygit
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
      opencode
      parallel
      pi-coding-agent
      prek
      prettier
      resvg
      ripgrep
      rsync
      ruff
      rust-analyzer
      (lib.lowPrio rustup)
      shellcheck
      shfmt
      sql-formatter
      sqlite
      starship
      statix
      stow
      stylua
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
    ];
  in {
    formatter.${system} = pkgs.alejandra;
    homeConfigurations = {
      christian = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
        ];
        extraSpecialArgs = {inherit tools;};
      };
    };
    packages.${system} = {
      christian = import ./image.nix {
        inherit pkgs tools;
        dotfilesSrc = dotfiles-root;
      };
      default = self.packages.${system}.christian;
    };
  };
}
