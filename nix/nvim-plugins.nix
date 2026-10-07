# Vendor the exact plugin checkouts pinned in Neovim's vim.pack lockfile, so
# the dev-container image works fully offline on first launch.
# vim.pack treats a directory already present under pack/core/opt/<name> as
# installed (no revision checks, no network), so seeding that tree suffices.
# Hashes live in nvim-plugins-hashes.json; refresh them with
# ./prefetch-nvim-plugins.sh [--refresh] after the lockfile moves.
{
  pkgs,
  dotfilesSrc,
}: let
  lock = builtins.fromJSON (builtins.readFile (dotfilesSrc + "/home/dot-config/nvim/nvim-pack-lock.json"));
  hashes = builtins.fromJSON (builtins.readFile ./nvim-plugins-hashes.json);
  fetchPlugin = name: data:
    pkgs.fetchgit {
      url = data.src;
      rev = data.rev;
      sha256 = hashes.${name} or (throw "nvim-plugins: no hash for '${name}' — run nix/prefetch-nvim-plugins.sh");
      # NOTE: no `leaveDotGit` on purpose: hashing `.git` depends on git
      # version and upstream ref movement (proven: same rev hashed differently
      # on another machine), which breaks CI. Trade-off: `vim.pack.update()`
      # cannot run in place on these seed copies; update on your main machine,
      # commit the lockfile, re-prefetch, rebuild the image.
    };
  plugins = pkgs.lib.mapAttrs fetchPlugin lock.plugins;
  copyPlugin = name: drv: "cp -r ${drv} $out/opt/${name}";
in
  pkgs.runCommand "nvim-pack-plugins" {} ''
    mkdir -p $out/opt
    ${pkgs.lib.concatStringsSep "\n" (pkgs.lib.mapAttrsToList copyPlugin plugins)}
    # Store trees are read-only; :packadd generates doc/tags on first use.
    chmod -R u+w $out
  ''
