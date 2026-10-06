{
  pkgs,
  tools,
  ...
}: let
  symlinks = import ./symlinks.nix {inherit pkgs;};
in {
  programs.bash.enable = false;

  home.username = "christian";
  home.homeDirectory = "/home/christian";

  home.packages = tools ++ [symlinks];

  home.stateVersion = "24.11";
}
