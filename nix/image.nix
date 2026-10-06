{
  pkgs,
  tools,
  dotfilesSrc,
}: let
  # Pre-seeded vim.pack plugins (pinned by nvim-pack-lock.json) so the first
  # launch inside the image needs no network. See ./nvim-plugins.nix.
  nvimPlugins = import ./nvim-plugins.nix {inherit pkgs dotfilesSrc;};
  homeDir = pkgs.runCommand "setup-dotfiles" {buildInputs = [pkgs.stow];} ''
    mkdir -p $out/root/dotfiles $out/tmp $out/etc
    echo "root:x:0:0::/root:${pkgs.fish}/bin/fish" > $out/etc/passwd
    echo "root:x:0:" > $out/etc/group
    cp -r ${dotfilesSrc}/. $out/root/dotfiles/
    chmod -R u+w $out/root/dotfiles
    cd $out/root/dotfiles
    stow --dotfiles home
    mkdir -p $out/root/.local/share/nvim/site/pack/core
    cp -r ${nvimPlugins}/opt $out/root/.local/share/nvim/site/pack/core/opt
  '';
in
  pkgs.dockerTools.buildImage {
    name = "dev";
    tag = "latest";

    copyToRoot = pkgs.buildEnv {
      name = "image-root";
      paths =
        tools
        ++ (with pkgs; [
          bash
          coreutils
          ncurses
          nix
          cacert
        ])
        ++ [homeDir];
      pathsToLink = ["/"];
    };

    config = {
      Cmd = ["${pkgs.fish}/bin/fish"];
      Env = [
        "PATH=/bin"
        "HOME=/root"
        "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
        ''NIX_CONFIG=experimental-features = nix-command flakes
build-users-group =''
      ];
      WorkingDir = "/root";
    };
  }
