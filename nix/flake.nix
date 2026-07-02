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

  outputs = { self, nixpkgs, home-manager, dotfiles-root, ... }: let
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
    tools = with pkgs; [
      aria2
      bash
      bat
      bat-extras.batdiff
      bat-extras.batgrep
      bat-extras.batman
      bat-extras.batpipe
      bat-extras.batwatch
      bat-extras.prettybat
      chafa
      curl
      dash
      dos2unix
      dust
      entr
      eza
      fastfetch
      fd
      fish
      fzf
      gh
      git
      git-lfs
      git-xet
      harlequin
      huggingface-hub
      hyperfine
      jj
      jq
      just
      lazygit
      lazydocker
      neovim
      nh
      opencode
      parallel
      prettier
      resvg
      ripgrep
      rsync
      starship
      stdenv.cc.cc.lib
      stow
      tlrc
      tokei
      unar
      unzip
      vulnix
      wget
      wl-clipboard
      xdg-utils
      yazi
      yq
      zellij
      zoxide
      _7zz
      alejandra
      bash-language-server
      dockerfile-language-server
      lua-language-server
      nixd
      shellcheck
      shfmt
      stylua
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
