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
      config.allowUnfree = true;
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
      deno
      dos2unix
      dust
      entr
      eza
      fastfetch
      fd
      fish
      fnm
      fzf
      gcc
      gh
      git
      git-lfs
      git-xet
      go
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
      nodejs
      ninja
      opencode
      p7zip
      parallel
      prek
      prettier
      resvg
      ripgrep
      rsync
      rustup
      starship
      stdenv.cc.cc.lib
      stow
      tlrc
      tokei
      unzip
      uv
      vulnix
      wget
      wl-clipboard
      xdg-utils
      yazi
      zellij
      zig
      zoxide
      yq
    ];
  in {
    homeConfigurations = {
      christian = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ 
          ./home.nix
          ({ pkgs, ... }: {
            home.file.".config/fish/conf.d/nix_ld_library_path.fish".text = ''
              set -gx LD_LIBRARY_PATH "${pkgs.stdenv.cc.cc.lib}/lib" $LD_LIBRARY_PATH
            '';
          })
        ];
        extraSpecialArgs = { inherit tools; };
      };
    };
    packages.${system} = {
      christian = import ./image.nix { inherit pkgs tools; dotfilesSrc = dotfiles-root; };
    };
  };
}
