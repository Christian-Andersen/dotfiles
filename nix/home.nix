{ pkgs, tools, ... }: let
  symlinks = pkgs.runCommand "symlinks" {} ''
    mkdir -p $out/bin
    ln -s ${pkgs.neovim}/bin/nvim $out/bin/vi
    ln -s ${pkgs._7zz}/bin/7zz $out/bin/7z
  '';
in {
  programs.bash.enable = false;

  home.username = "christian";
  home.homeDirectory = "/home/christian";

  home.packages = tools ++ [ symlinks ];

  home.stateVersion = "24.11";
}
