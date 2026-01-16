return {
	-- tokyonight
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		config = function()
			require("tokyonight").setup({
				styles = {
					comments = { italic = false },
				},
				on_colors = function(colors)
					colors.black = "#000000"
					colors.bg = "#000000"
				end,
			})
		end,
	},

	-- catppuccin
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "macchiato", -- latte, frappe, macchiato, mocha
			})
		end,
	},

	-- nightfox
	{ "EdenEast/nightfox.nvim", priority = 1000 },

	-- kanagawa
	{ "rebelot/kanagawa.nvim", priority = 1000 },

	-- gruvbox
	{ "ellisonleao/gruvbox.nvim", priority = 1000, config = true },

	-- github-theme
	{
		"projekt0n/github-nvim-theme",
		priority = 1000,
		config = function()
			require("github-theme").setup()
		end,
	},

	-- rose-pine
	{
		"rose-pine/neovim",
		name = "rose-pine",
		priority = 1000,
		config = function()
			require("rose-pine").setup()
		end,
	},

	-- sonokai
	{ "sainnhe/sonokai", priority = 1000 },

	-- onedark
	{ "navarasu/onedark.nvim", priority = 1000, config = true },

	-- dracula
	{ "Mofiqul/dracula.nvim", priority = 1000, config = true },

	-- everforest
	{ "sainnhe/everforest", priority = 1000 },

	-- vscode
	{ "Mofiqul/vscode.nvim", priority = 1000 },

	-- cyberdream
	{ "scottmckendry/cyberdream.nvim", priority = 1000 },

	-- material
	{ "marko-cerovac/material.nvim", priority = 1000 },

	-- nord
	{ "shaunsingh/nord.nvim", priority = 1000 },

	-- moonfly
	{ "bluz71/vim-moonfly-colors", priority = 1000 },

	-- nordic
	{ "AlexvZyl/nordic.nvim", priority = 1000 },

	-- gruvbox-baby
	{ "luisiacc/gruvbox-baby", priority = 1000 },

	-- onedarkpro
	{ "olimorris/onedarkpro.nvim", priority = 1000 },

	-- gruvbox-material
	{ "sainnhe/gruvbox-material", priority = 1000 },
}

