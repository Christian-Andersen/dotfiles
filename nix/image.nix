{ pkgs, tools, dotfilesSrc }:
let
  homeDir = pkgs.runCommand "setup-dotfiles" { buildInputs = [ pkgs.stow ]; } ''
    mkdir -p $out/root/dotfiles $out/tmp $out/etc
    echo "root:x:0:0::/root:${pkgs.fish}/bin/fish" > $out/etc/passwd
    echo "root:x:0:" > $out/etc/group
    cp -r ${dotfilesSrc}/. $out/root/dotfiles/
    chmod -R u+w $out/root/dotfiles
    cd $out/root/dotfiles
    stow --dotfiles home
  '';
in pkgs.dockerTools.buildImage {
  name = "dev";
  tag = "latest";

  copyToRoot = pkgs.buildEnv {
    name = "image-root";
    paths = tools ++ (with pkgs; [ bash coreutils ncurses ]) ++ [ homeDir ];
    pathsToLink = [ "/" ];
  };

  config = {
    Cmd = [ "${pkgs.fish}/bin/fish" ];
    Env = [ "PATH=/bin" "HOME=/root" ];
    WorkingDir = "/root";
  };
}
