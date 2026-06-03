{ pkgs, tools, ... }: {
  programs.bash.enable = false;

  home.username = "christian";
  home.homeDirectory = "/home/christian";

  home.packages = tools;

  home.stateVersion = "24.11";
}
