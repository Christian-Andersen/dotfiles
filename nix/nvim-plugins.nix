# Vendor the Neovim plugins the config uses, sourced straight from nixpkgs'
# `vimPlugins`, so the dev-container image works fully offline on first launch.
# Plugin versions ride the normal flake.lock bump (`just nix-update`); nixpkgs
# owns the pinning. Entries are `pack/core/opt` names (as vim.pack sees them,
# dots and all) mapped to their nixpkgs `vimPlugins` attribute.
# vim.pack treats a directory already present under pack/core/opt/<name> as
# installed (no revision checks, no network), so seeding that tree suffices.
{pkgs}: let
  plugins = {
    "blink.cmp" = pkgs.vimPlugins.blink-cmp;
    "bufferline.nvim" = pkgs.vimPlugins.bufferline-nvim;
    "catppuccin" = pkgs.vimPlugins.catppuccin-nvim;
    "conform.nvim" = pkgs.vimPlugins.conform-nvim;
    "gitsigns.nvim" = pkgs.vimPlugins.gitsigns-nvim;
    "gruvbox-material" = pkgs.vimPlugins.gruvbox-material;
    "kanagawa.nvim" = pkgs.vimPlugins.kanagawa-nvim;
    "lazydev.nvim" = pkgs.vimPlugins.lazydev-nvim;
    "lualine.nvim" = pkgs.vimPlugins.lualine-nvim;
    "mini.icons" = pkgs.vimPlugins.mini-icons;
    "nightfox.nvim" = pkgs.vimPlugins.nightfox-nvim;
    "nvim-autopairs" = pkgs.vimPlugins.nvim-autopairs;
    "nvim-colorizer.lua" = pkgs.vimPlugins.nvim-colorizer-lua;
    "nvim-dap" = pkgs.vimPlugins.nvim-dap;
    "nvim-dap-python" = pkgs.vimPlugins.nvim-dap-python;
    "nvim-dap-view" = pkgs.vimPlugins.nvim-dap-view;
    "nvim-lint" = pkgs.vimPlugins.nvim-lint;
    "nvim-lspconfig" = pkgs.vimPlugins.nvim-lspconfig;
    "nvim-treesitter" = pkgs.vimPlugins.nvim-treesitter;
    "nvim-web-devicons" = pkgs.vimPlugins.nvim-web-devicons;
    "plenary.nvim" = pkgs.vimPlugins.plenary-nvim;
    "rainbow-delimiters.nvim" = pkgs.vimPlugins.rainbow-delimiters-nvim;
    "render-markdown.nvim" = pkgs.vimPlugins.render-markdown-nvim;
    "rose-pine" = pkgs.vimPlugins.rose-pine;
    "snacks.nvim" = pkgs.vimPlugins.snacks-nvim;
    "tiny-cmdline.nvim" = pkgs.vimPlugins.tiny-cmdline-nvim;
    "todo-comments.nvim" = pkgs.vimPlugins.todo-comments-nvim;
    "tokyonight.nvim" = pkgs.vimPlugins.tokyonight-nvim;
    "which-key.nvim" = pkgs.vimPlugins.which-key-nvim;
  };
  copyPlugin = name: drv: "cp -r ${drv} $out/opt/${name}";
in
  pkgs.runCommand "nvim-pack-plugins" {} ''
    mkdir -p $out/opt
    ${pkgs.lib.concatStringsSep "\n" (pkgs.lib.mapAttrsToList copyPlugin plugins)}
    # Store trees are read-only; :packadd generates doc/tags on first use.
    chmod -R u+w $out
  ''
