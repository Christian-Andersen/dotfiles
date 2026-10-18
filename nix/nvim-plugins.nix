# Vendor the Neovim plugins the config uses, sourced straight from nixpkgs'
# `vimPlugins`, so the dev-container image works fully offline on first launch.
# Plugin versions ride the normal flake.lock bump (`just nix-update`) instead of
# a hand-maintained hash file; nixpkgs owns the pinning.
# vim.pack treats a directory already present under pack/core/opt/<name> as
# installed (no revision checks, no network), so seeding that tree suffices.
{
  pkgs,
  dotfilesSrc,
}: let
  lock = builtins.fromJSON (builtins.readFile (dotfilesSrc + "/home/dot-config/nvim/nvim-pack-lock.json"));

  # vim.pack names → nixpkgs vimPlugins attribute names. Most map by turning the
  # `.` in `<name>.nvim` into `-`; exceptions go here.
  overrides = {
    catppuccin = "catppuccin-nvim";
  };
  attrFor = name: overrides.${name} or (builtins.replaceStrings ["."] ["-"] name);
  fetchPlugin = name: let
    attr = attrFor name;
  in
    if builtins.hasAttr attr pkgs.vimPlugins
    then pkgs.vimPlugins.${attr}
    else throw "nvim-plugins: '${name}' has no nixpkgs vimPlugins attribute (tried '${attr}')";

  plugins = pkgs.lib.mapAttrs (name: _: fetchPlugin name) lock.plugins;
  copyPlugin = name: drv: "cp -r ${drv} $out/opt/${name}";
in
  pkgs.runCommand "nvim-pack-plugins" {} ''
    mkdir -p $out/opt
    ${pkgs.lib.concatStringsSep "\n" (pkgs.lib.mapAttrsToList copyPlugin plugins)}
    # Store trees are read-only; :packadd generates doc/tags on first use.
    chmod -R u+w $out
  ''
