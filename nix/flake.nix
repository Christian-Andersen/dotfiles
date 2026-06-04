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
      bat
      chafa
      curl
      deno
      dos2unix
      dust
      eza
      fastfetch
      fd
      fish
      fnm
      fzf
      gcc
      gh
      git
      go
      huggingface-hub
      hyperfine
      jj
      jq
      just
      lazygit
      lazydocker
      neovim
      ninja
      opencode
      openssh
      openssl
      p7zip
      parallel
      prek
      resvg
      ripgrep
      rsync
      rustup
      starship
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
    ];
  in {
    homeConfigurations = {
      dev = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
        extraSpecialArgs = { inherit tools; };
      };
    };
    packages.${system} = {
      dev = import ./image.nix { inherit pkgs tools; dotfilesSrc = dotfiles-root; };
    };
  };
}
