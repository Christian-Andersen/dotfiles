{
  pkgs,
  tools,
  dotfilesSrc,
}: let
  # Pre-seeded vim.pack plugins (sourced from nixpkgs' vimPlugins) so the first
  # launch inside the image needs no network. See ./nvim-plugins.nix.
  nvimPlugins = import ./nvim-plugins.nix {inherit pkgs;};
  symlinks = import ./symlinks.nix {inherit pkgs;};
  # Prebuilt tree-sitter parsers (see ./nvim-parsers.nix).
  nvimParsers = import ./nvim-parsers.nix {inherit pkgs;};
  homeDir = pkgs.runCommand "setup-dotfiles" {buildInputs = [pkgs.stow];} ''
    mkdir -p $out/root/dotfiles $out/tmp $out/etc $out/usr/bin
    ln -s ${pkgs.coreutils}/bin/env $out/usr/bin/env
    echo "root:x:0:0::/root:${pkgs.fish}/bin/fish" > $out/etc/passwd
    echo "root:x:0:" > $out/etc/group
    cp -r ${dotfilesSrc}/. $out/root/dotfiles/
    chmod -R u+w $out/root/dotfiles
    cd $out/root/dotfiles
    stow --dotfiles home
    mkdir -p $out/root/.local/share/nvim/site/pack/core
    cp -r ${nvimPlugins}/opt $out/root/.local/share/nvim/site/pack/core/opt
    mkdir -p $out/root/.local/share/nvim/site
    cp -r ${nvimParsers}/parser ${nvimParsers}/parser-info $out/root/.local/share/nvim/site/
    # Empty queries dir: get_installed() scans it on every startup.
    mkdir -p $out/root/.local/share/nvim/site/queries
    chmod -R u+w $out/root/.local/share/nvim/site/parser $out/root/.local/share/nvim/site/parser-info
  '';
in
  pkgs.dockerTools.buildImage {
    name = "dotfiles";
    tag = "latest";

    copyToRoot = pkgs.buildEnv {
      name = "image-root";
      # ncurses and ghostty both ship share/terminfo/g/ghostty.
      ignoreCollisions = true;
      paths =
        tools
        ++ [symlinks]
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
        "SHELL=${pkgs.fish}/bin/fish"
        "XDG_PROJECTS_DIR=/root/Projects"
        "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
        ''          NIX_CONFIG=experimental-features = nix-command flakes
          build-users-group =''
      ];
      WorkingDir = "/root";
    };
  }
