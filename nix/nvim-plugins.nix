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
  # Used only to synthesize the image's vim.pack lockfile. The revisions are
  # placeholders: the seeded plugin directories are not git checkouts, so this
  # stops vim.pack from trying to repair the lock with `git` on startup.
  sources = {
    "blink.cmp" = "https://github.com/saghen/blink.cmp";
    "bufferline.nvim" = "https://github.com/akinsho/bufferline.nvim";
    "catppuccin" = "https://github.com/catppuccin/nvim";
    "conform.nvim" = "https://github.com/stevearc/conform.nvim";
    "gitsigns.nvim" = "https://github.com/lewis6991/gitsigns.nvim";
    "gruvbox-material" = "https://github.com/sainnhe/gruvbox-material";
    "kanagawa.nvim" = "https://github.com/rebelot/kanagawa.nvim";
    "lazydev.nvim" = "https://github.com/folke/lazydev.nvim";
    "lualine.nvim" = "https://github.com/nvim-lualine/lualine.nvim";
    "mini.icons" = "https://github.com/echasnovski/mini.icons";
    "nightfox.nvim" = "https://github.com/EdenEast/nightfox.nvim";
    "nvim-autopairs" = "https://github.com/windwp/nvim-autopairs";
    "nvim-colorizer.lua" = "https://github.com/NvChad/nvim-colorizer.lua";
    "nvim-dap" = "https://github.com/mfussenegger/nvim-dap";
    "nvim-dap-python" = "https://github.com/mfussenegger/nvim-dap-python";
    "nvim-dap-view" = "https://github.com/igorlfs/nvim-dap-view";
    "nvim-lint" = "https://github.com/mfussenegger/nvim-lint";
    "nvim-lspconfig" = "https://github.com/neovim/nvim-lspconfig";
    "nvim-treesitter" = "https://github.com/nvim-treesitter/nvim-treesitter";
    "nvim-web-devicons" = "https://github.com/nvim-tree/nvim-web-devicons";
    "plenary.nvim" = "https://github.com/nvim-lua/plenary.nvim";
    "rainbow-delimiters.nvim" = "https://github.com/HiPhish/rainbow-delimiters.nvim";
    "render-markdown.nvim" = "https://github.com/MeanderingProgrammer/render-markdown.nvim";
    "rose-pine" = "https://github.com/rose-pine/neovim";
    "snacks.nvim" = "https://github.com/folke/snacks.nvim";
    "tiny-cmdline.nvim" = "https://github.com/rachartier/tiny-cmdline.nvim";
    "todo-comments.nvim" = "https://github.com/folke/todo-comments.nvim";
    "tokyonight.nvim" = "https://github.com/folke/tokyonight.nvim";
    "which-key.nvim" = "https://github.com/folke/which-key.nvim";
  };
  copyPlugin = name: drv: "cp -r ${drv} $out/opt/${name}";
  package = pkgs.runCommand "nvim-pack-plugins" {} ''
    mkdir -p $out/opt
    ${pkgs.lib.concatStringsSep "\n" (pkgs.lib.mapAttrsToList copyPlugin plugins)}
    # Store trees are read-only; :packadd generates doc/tags on first use.
    chmod -R u+w $out
  '';
  lock = pkgs.writeText "nvim-pack-lock.json" (builtins.toJSON {
    plugins =
      pkgs.lib.mapAttrs' (name: src: {
        inherit name;
        value =
          {
            rev = "0000000000000000000000000000000000000000";
            inherit src;
          }
          // pkgs.lib.optionalAttrs (name == "blink.cmp") {
            # Match vim.pack's serialized `version` format.
            version = "'v1'";
          };
      })
      sources;
  });
in
  assert pkgs.lib.assertMsg (pkgs.lib.attrNames plugins == pkgs.lib.attrNames sources)
  "nvim-plugins.nix: every plugin needs a matching source URL for the lockfile";
    package // {inherit lock;}
