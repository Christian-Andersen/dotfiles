-- Neovim 0.12, vim.pack, everything eager (nothing is lazy-loaded).
-- Load order matters: leader -> ui2 -> pack.add -> plugin setup. blink before
-- LSP capabilities, mason before mason-lspconfig, colorscheme before lualine,
-- dashboard section before snacks.setup(), diagnostic patch before LSP output.

-- [[ BOOTSTRAP ]] ------------------------------------------------------------

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- Must precede plugin setup: which-key and <leader> maps read it at define time.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.filetype.add({
	extension = {
		gotmpl = "gotmpl",
	},
	pattern = {
		[".env.*"] = "env",
		[".env"] = "env",
	},
})

vim.g.have_nerd_font = true

-- Floating cmdline. targets = "msg" keeps :w output out of the cmdline/pager
-- window, where <CR> could drop the cursor into it (neovim/neovim#40282).
require("vim._core.ui2").enable({
	enable = true,
	msg = {
		targets = "msg",
		cmd = { height = 0.5 },
		dialog = { height = 0.5 },
		msg = { height = 0.5, timeout = 4000 },
		pager = { height = 0.5 },
	},
})

-- [[ OPTIONS ]] --------------------------------------------------------------

vim.api.nvim_create_user_command("W", "write <args>", {
	bang = true,
	nargs = "*",
	complete = "file",
	desc = "Alias for :w",
})

vim.o.number = true
vim.o.relativenumber = true
vim.o.termguicolors = true
vim.o.signcolumn = "yes"
vim.o.cursorline = true
vim.o.winborder = "rounded"
vim.o.cmdheight = 0 -- ui2/tiny-cmdline draw the cmdline in a float
vim.o.mouse = "a"
vim.o.breakindent = true
vim.o.smoothscroll = true
vim.o.scrolloff = 10
vim.o.splitkeep = "screen"
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = "split"
vim.o.confirm = true

vim.o.splitright = true
vim.o.splitbelow = true

vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Neovim's runtime lua ftplugin sets no indent options, so removing this makes
-- Lua buffers 8-wide. ftplugins still override per filetype.
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- cmdheight=0 hides pending keys and macro recording; lualine renders %S instead.
vim.o.showcmd = true
vim.o.showcmdloc = "statusline"

-- [[ KEYMAPS ]] --------------------------------------------------------------

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostic location list" })
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
vim.keymap.set("n", "<leader>b", "<C-^>", { desc = "Go to last [b]uffer" })

vim.keymap.set("n", "<leader>y", function()
	local view = vim.fn.winsaveview()
	vim.cmd("silent %yank +")
	vim.cmd("silent %yank")
	vim.fn.winrestview(view)
	vim.notify("Yanked " .. vim.api.nvim_buf_line_count(0) .. " lines to clipboard (+)", vim.log.levels.INFO)
end, { desc = "[y]ank whole buffer to clipboard" })

-- Visual selection is sent as a fenced code block tagged with the filetype.
local function google_ai_search()
	local code_block = ""
	local mode = vim.api.nvim_get_mode().mode

	if mode == "v" or mode == "V" or mode == "\22" then
		vim.cmd('noau normal! "vy"')
		local selected = vim.fn.getreg("v"):match("^%s*(.-)%s*$")
		local ft = vim.bo.filetype
		if ft ~= "" then
			code_block = "```" .. ft .. "\n" .. selected .. "\n```\n"
		else
			code_block = "```\n" .. selected .. "\n```\n"
		end
	end

	vim.ui.input({
		prompt = "Google AI Prompt: ",
	}, function(input)
		if not input or input == "" then
			return
		end
		local query = code_block .. input
		local encoded = query
			:gsub("([^%w ])", function(c)
				return string.format("%%%02X", string.byte(c))
			end)
			:gsub(" ", "+")
		local url = "https://www.google.com/search?udm=50&q=" .. encoded
		vim.fn.jobstart({ "xdg-open", url }, { detach = true })
	end)
end
vim.keymap.set({ "n", "v" }, "<leader><CR>", google_ai_search, { desc = "Search Google AI with Prompt" })

-- [[ FILE SLOTS ]] -----------------------------------------------------------

-- Number -> file slots ("marks for files"), persisted in stdpath("state") and
-- scoped to the git root (so main.rs can hold slot 1 in every project).
local slots_path = vim.fn.stdpath("state") .. "/file-slots.json"
local slots = {}
do
	local f = io.open(slots_path, "r")
	if f then
		-- luanil: JSON null decodes to nil. The key rewrite only matters for files
		-- from older versions, which stored numeric slot keys.
		local ok, data = pcall(vim.json.decode, f:read("*a"), { luanil = { object = true, array = true } })
		f:close()
		if ok and type(data) == "table" then
			for project, project_slots in pairs(data) do
				data[project] = {}
				for n, file in pairs(project_slots) do
					data[project][tostring(n)] = file
				end
			end
			slots = data
		end
	end
end

-- Current project: git root of the current buffer, else cwd.
local function slots_project()
	local name = vim.api.nvim_buf_get_name(0)
	return (name ~= "" and vim.fs.root(name, ".git")) or vim.fn.getcwd()
end

local function slots_save()
	local f = io.open(slots_path, "w")
	if not f then
		vim.notify("Cannot write " .. slots_path, vim.log.levels.WARN)
		return
	end
	f:write(vim.json.encode(slots))
	f:close()
end

local function slot_delete(project, n)
	slots[project][tostring(n)] = nil
	if next(slots[project]) == nil then
		slots[project] = nil
	end
	slots_save()
end

local function slot_set(n)
	local name = vim.api.nvim_buf_get_name(0)
	if name == "" or vim.bo.buftype ~= "" then
		vim.notify("Not a file buffer", vim.log.levels.WARN)
		return
	end
	local project = slots_project()
	slots[project] = slots[project] or {}
	slots[project][tostring(n)] = name
	slots_save()
	vim.notify(("slot %d = %s"):format(n, vim.fn.fnamemodify(name, ":~:.")), vim.log.levels.INFO)
end

-- Unmark the current file.
local function slot_unset()
	local project = slots_project()
	local name = vim.api.nvim_buf_get_name(0)
	for n, file in pairs(slots[project] or {}) do
		if file == name then
			slot_delete(project, n)
			vim.notify(("slot %s cleared"):format(n), vim.log.levels.INFO)
			return
		end
	end
	vim.notify("Current file is not pinned", vim.log.levels.WARN)
end

local function slot_goto(n)
	local project = slots_project()
	local name = slots[project] and slots[project][tostring(n)]
	if not name then
		vim.notify("slot " .. n .. " is empty", vim.log.levels.WARN)
		return
	end
	if vim.fn.filereadable(name) == 0 then
		slot_delete(project, n)
		vim.notify(("slot %d target is gone, slot cleared"):format(n), vim.log.levels.WARN)
		return
	end
	local buf = vim.fn.bufadd(name)
	vim.fn.bufload(buf)
	-- Prefer an existing window in this tabpage, else reuse the current one.
	for _, win in ipairs(vim.fn.win_findbuf(buf)) do
		if vim.api.nvim_win_get_tabpage(win) == vim.api.nvim_get_current_tabpage() then
			vim.api.nvim_set_current_win(win)
			return
		end
	end
	vim.api.nvim_win_set_buf(0, buf)
end

-- Snacks picker: <CR> opens, typing filters. Deleting lives on <leader>md.
local function slot_list()
	local project = slots_project()
	local items = {}
	for n = 1, 9 do
		local file = slots[project] and slots[project][tostring(n)]
		if file then
			items[#items + 1] = {
				slot = n,
				file = file, -- enables the file preview
				pos = { 1, 0 },
				text = ("%d  %s"):format(n, (file:gsub("^" .. vim.pesc(project) .. "/", ""))),
			}
		end
	end
	if #items == 0 then
		vim.notify("No file slots in " .. vim.fn.fnamemodify(project, ":~"), vim.log.levels.INFO)
		return
	end
	require("snacks").picker.pick({
		title = "File Slots",
		items = items,
		format = "text",
		confirm = function(picker, item)
			if item then
				picker:close()
				slot_goto(item.slot)
			end
		end,
	})
end
for n = 1, 9 do
	vim.keymap.set("n", "<leader>" .. n, function()
		slot_goto(n)
	end, { desc = "Go to file slot " .. n })
	vim.keymap.set("n", "<leader>m" .. n, function()
		slot_set(n)
	end, { desc = "Mark file as slot " .. n })
end
vim.keymap.set("n", "<leader>ml", slot_list, { desc = "List file slots" })
vim.keymap.set("n", "<leader>md", slot_unset, { desc = "Delete this file's slot" })

-- [[ AUTOCOMMANDS ]] ---------------------------------------------------------

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- [[ PLUGIN SPEC ]] ----------------------------------------------------------

-- On update the plugin may not be loaded yet; packadd first or :TSUpdate is nil.
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		if ev.data.spec.name == "nvim-treesitter" and ev.data.kind == "update" then
			if not ev.data.active then
				vim.cmd.packadd("nvim-treesitter")
			end
			vim.cmd("TSUpdate")
		end
	end,
})

-- Bundled opt packages, not managed by vim.pack.
vim.cmd.packadd("nvim.undotree")
vim.cmd.packadd("nvim.difftool")

-- add() also packadds everything during startup, so no per-plugin packadd below.
-- confirm = false: never prompt, safe in a fresh container. Lockfile is untracked.
vim.pack.add({
	-- Core
	"https://github.com/folke/snacks.nvim",
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/folke/lazydev.nvim",
	-- Both icon providers are needed: snacks prefers mini.icons, lualine's
	-- filetype component hard-codes an nvim-web-devicons fallback.
	"https://github.com/echasnovski/mini.icons",
	"https://github.com/nvim-tree/nvim-web-devicons",
	-- Completion
	{ src = "https://github.com/saghen/blink.cmp", version = "v1" },
	-- Formatting & Linting
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/mfussenegger/nvim-lint",
	-- Debug
	"https://github.com/mfussenegger/nvim-dap",
	"https://github.com/igorlfs/nvim-dap-view",
	"https://github.com/mfussenegger/nvim-dap-python",
	-- Misc
	"https://github.com/rachartier/tiny-cmdline.nvim",
	"https://github.com/windwp/nvim-autopairs",
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/folke/todo-comments.nvim",
	-- Indirect dependency of todo-comments' search (:TodoQuickFix).
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/MeanderingProgrammer/render-markdown.nvim",
	"https://github.com/NvChad/nvim-colorizer.lua",
	"https://github.com/HiPhish/rainbow-delimiters.nvim",
	-- Themes
	"https://github.com/folke/tokyonight.nvim",
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
	"https://github.com/rebelot/kanagawa.nvim",
	{ src = "https://github.com/rose-pine/neovim", name = "rose-pine" },
	"https://github.com/sainnhe/gruvbox-material",
	"https://github.com/EdenEast/nightfox.nvim",
	-- Mason
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/mason-org/mason-lspconfig.nvim",
	"https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
}, { confirm = false })

-- [[ MASON ]] ---------------------------------------------------------------

-- taplo is absent on purpose: the taplo LSP package provides the binary conform uses.
require("mason").setup()
require("mason-tool-installer").setup({
	ensure_installed = {
		-- Formatters
		"oxfmt",
		"oxlint",
		"buf",
		"clang-format",
		"markdownlint-cli2",
		"shfmt",
		"sql-formatter",
		"stylua",
		"yamlfmt",

		-- Linters
		"shellcheck",
		"dotenv-linter",
		"statix",
		"golangci-lint",

		-- Debuggers
		"delve",
		"debugpy",
	},
	auto_update = false,
	run_on_start = true,
})

-- [[ TINY-CMDLINE ]] ---------------------------------------------------------

-- setup() deep-merges over defaults. on_reposition keeps blink's menu aligned.
---@diagnostic disable-next-line: missing-fields
require("tiny-cmdline").setup({
	on_reposition = require("tiny-cmdline").adapters.blink,
})

-- [[ SNACKS ]] ---------------------------------------------------------------

-- Dashboard "Recent" by frecency. WHY custom: the stock recent_files section walks
-- vim.v.oldfiles in MRU order and has no frecency option; picker.matcher.frecency
-- only re-ranks picker matches. This reuses snacks' own filtered file list and
-- changes only the ordering. Must be registered before setup(): sections are
-- resolved by name at render time. `.new()` also installs the BufWinEnter tracker.
local Snacks = require("snacks")

Snacks.dashboard.sections.frecency_recent = function(opts)
	local limit = opts.limit or 5
	local root = opts.cwd and vim.fs.normalize(opts.cwd == true and vim.fn.getcwd() or opts.cwd) or nil
	local oldfiles_opts = root and { filter = { [root] = true } } or nil

	return function()
		local frecency = require("snacks.picker.core.frecency").new()
		local files = {}
		for file in Snacks.dashboard.oldfiles(oldfiles_opts) do
			if not opts.filter or opts.filter(file) then
				local i = #files + 1
				files[i] = {
					file = file,
					i = i, -- shada position, tiebreak below
					-- recent = true is required: without it untracked files score 0
					-- on a fresh install and the order degrades to plain MRU.
					---@diagnostic disable-next-line: missing-fields
					score = frecency:get({ file = file, recent = true }),
				}
			end
		end
		table.sort(files, function(a, b)
			if a.score == b.score then
				return a.i < b.i
			end
			return a.score > b.score
		end)

		local ret = {} ---@type snacks.dashboard.Section
		for i = 1, math.min(limit, #files) do
			local file = files[i].file
			ret[i] = {
				file = file,
				icon = "file",
				action = ":e " .. vim.fn.fnameescape(file),
				autokey = true, -- keeps the 1-0 dashboard bindings working
			}
		end
		return ret
	end
end

require("snacks").setup({
	-- The stock dashboard ships a `startup` section that requires lazy.nvim.
	dashboard = {
		sections = {
			{ section = "header" },
			{ section = "keys", gap = 1, padding = 1 },
			{ section = "frecency_recent", cwd = true, limit = 10, title = "Recent", pane = 2 },
		},
	},
	bigfile = { enabled = true },
	explorer = { enabled = true },
	indent = { enabled = true },
	input = { enabled = true },
	picker = {
		enabled = true,
		matcher = {
			frecency = true,
		},
		sources = {
			explorer = {
				auto_close = true,
				hidden = true, -- dotfiles visible, .gitignore still respected
			},
		},
	},
	notifier = { enabled = true },
	quickfile = { enabled = true },
	scope = { enabled = true },
	scroll = { enabled = true },
	statuscolumn = { enabled = true },
	words = { enabled = true },
	git = { enabled = true },
	gitbrowse = {
		enabled = true,
		what = "repo",
		-- remote_patterns REPLACES snacks' defaults (it is a list); generic rules
		-- are reproduced in full and the Forgejo rewrites come last.
		remote_patterns = {
			{ "^(https?://.*)%.git$", "%1" },
			{ "^git@(.+):(.+)%.git$", "https://%1/%2" },
			{ "^git@(.+):(.+)$", "https://%1/%2" },
			{ "^git@(.+)/(.+)$", "https://%1/%2" },
			{ "^org%-%d+@(.+):(.+)%.git$", "https://%1/%2" },
			{ "^ssh://git@(.*)$", "https://%1" },
			{ "^ssh://([^:/]+)(:%d+)/(.*)$", "https://%1/%3" },
			{ "^ssh://([^/]+)/(.*)$", "https://%1/%2" },
			{ "ssh%.dev%.azure%.com/v3/(.*)/(.*)$", "dev.azure.com/%1/_git/%2" },
			{ "^https://%w*@(.*)", "https://%1" },
			{ "^git@(.*)", "https://%1" },
			{ ":%d+", "" },
			{ "%.git$", "" },
			-- Forgejo: ssh forgejo:2222 -> web UI on server:3000.
			{ "^forgejo:(.+)$", "https://server:3000/%1" },
			{ "^https://forgejo/", "https://server:3000/" },
		},
		url_patterns = {
			["server:3000"] = {
				branch = "/src/branch/{branch}",
				file = "/src/branch/{branch}/{file}#L{line_start}-L{line_end}",
				permalink = "/src/{commit}/{file}#L{line_start}-L{line_end}",
				commit = "/commit/{commit}",
			},
		},
		-- snacks normalizes to https; the local Forgejo UI is plain http.
		open = function(url)
			vim.ui.open((url:gsub("^https://server:3000", "http://server:3000")))
		end,
	},
	lazygit = { enabled = true },
	image = { enabled = true },
	toggle = { enabled = true },
})

-- Deferred: the snacks global is not available at require time.
vim.schedule(function()
	_G.dd = function(...)
		Snacks.debug.inspect(...)
	end
	_G.bt = function()
		Snacks.debug.backtrace()
	end
	vim.print = _G.dd -- intentional override
end)

-- Table-driven. mode defaults to "n"; desc doubles as the which-key label;
-- nowait is only needed where a longer mapping shares a prefix (grr).
local snacks_keys = {
	{
		"<leader><space>",
		function()
			Snacks.picker.buffers()
		end,
		desc = "Buffers [ ]",
	},
	{
		"<leader>sf",
		function()
			Snacks.picker.files({ hidden = true })
		end,
		desc = "Search [f]iles",
	},
	{
		"<leader>sg",
		function()
			Snacks.picker.grep()
		end,
		desc = "Search by [g]rep",
	},
	{
		"<leader>:",
		function()
			Snacks.picker.command_history()
		end,
		desc = "Command history [:]",
	},
	{
		"<leader>n",
		function()
			Snacks.notifier.show_history()
		end,
		desc = "[n]otification history",
	},
	{
		"<leader>e",
		function()
			Snacks.explorer()
		end,
		desc = "File [e]xplorer",
	},
	{
		"<leader>st",
		"<cmd>TodoQuickFix<CR>",
		desc = "Search [t]odo comments",
	},
	{
		"<leader>sT",
		"<cmd>TodoQuickFix keywords=TODO,FIX,FIXME<CR>",
		desc = "Search [T]odo/Fixme",
	},
	{
		"<leader>sh",
		function()
			Snacks.picker.help()
		end,
		desc = "Search [h]elp",
	},
	{
		"<leader>sk",
		function()
			Snacks.picker.keymaps()
		end,
		desc = "Search [k]eymaps",
	},
	{
		"<leader>ss",
		function()
			Snacks.picker.pickers()
		end,
		desc = "Search [s]elect (pickers)",
	},
	{
		"<leader>sw",
		function()
			Snacks.picker.grep_word()
		end,
		desc = "Search current [w]ord",
		mode = { "n", "x" },
	},
	{
		"<leader>sd",
		function()
			Snacks.picker.diagnostics()
		end,
		desc = "Search [d]iagnostics",
	},
	{
		"<leader>sr",
		function()
			Snacks.picker.resume()
		end,
		desc = "Search [r]esume",
	},
	{
		"<leader>s.",
		function()
			Snacks.picker.recent()
		end,
		desc = "Search recent files [.]",
	},
	{
		"<leader>/",
		function()
			Snacks.picker.lines()
		end,
		desc = "Search buffer [/] lines",
	},
	{
		"<leader>s/",
		function()
			Snacks.picker.grep_buffers()
		end,
		desc = "Search open buffers [/]",
	},
	{
		"<leader>sn",
		function()
			Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
		end,
		desc = "Search [n]eovim files",
	},
	{
		"\\",
		function()
			Snacks.explorer()
		end,
		desc = "Toggle explorer [\\]",
	},
	{
		"<leader>gb",
		function()
			Snacks.git.blame_line()
		end,
		desc = "Git [b]lame line",
	},
	{
		"<leader>gB",
		function()
			Snacks.gitbrowse()
		end,
		desc = "Git [B]rowse",
	},
	{
		"<leader>gg",
		function()
			Snacks.lazygit()
		end,
		desc = "Lazy[g]it",
	},
	{
		"<leader>gl",
		function()
			Snacks.lazygit.log()
		end,
		desc = "Lazygit [l]og (CWD)",
	},
	{
		"<leader>gf",
		function()
			Snacks.lazygit.log_file()
		end,
		desc = "Lazygit current [f]ile history",
	},
	{
		"gd",
		function()
			Snacks.picker.lsp_definitions()
		end,
		desc = "Go to [d]efinition",
	},
	{
		"gD",
		function()
			Snacks.picker.lsp_declarations()
		end,
		desc = "Go to [D]eclaration",
	},
	{
		"grr",
		function()
			Snacks.picker.lsp_references()
		end,
		nowait = true,
		desc = "Go to [r]eferences",
	},
	{
		"gI",
		function()
			Snacks.picker.lsp_implementations()
		end,
		desc = "Go to [I]mplementation",
	},
	{
		"gy",
		function()
			Snacks.picker.lsp_type_definitions()
		end,
		desc = "Go to t[y]pe definition",
	},
	{
		"<leader>sl",
		function()
			Snacks.picker.lsp_symbols()
		end,
		desc = "LSP [s]ymbols",
	},
	{
		"<leader>sL",
		function()
			Snacks.picker.lsp_workspace_symbols()
		end,
		desc = "LSP workspace [S]ymbols",
	},
	{
		"<leader>th",
		function()
			Snacks.toggle.inlay_hints():toggle()
		end,
		desc = "Toggle inlay [h]ints",
	},
	{
		"<leader>ts",
		function()
			Snacks.toggle.option("spell", { name = "Spelling" }):toggle()
		end,
		desc = "Toggle [s]pelling",
	},
	{
		"<leader>tw",
		function()
			Snacks.toggle.option("wrap", { name = "Wrap" }):toggle()
		end,
		desc = "Toggle [w]rap",
	},
	{
		"<leader>tr",
		function()
			Snacks.toggle.option("relativenumber", { name = "Relative Number" }):toggle()
		end,
		desc = "Toggle [r]elative number",
	},
	{
		"<leader>td",
		function()
			Snacks.toggle.diagnostics():toggle()
		end,
		desc = "Toggle [d]iagnostics",
	},
	{
		"<leader>tl",
		function()
			Snacks.toggle.line_number():toggle()
		end,
		desc = "Toggle [l]ine number",
	},
	{
		"<leader>tc",
		function()
			Snacks.toggle
				.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
				:toggle()
		end,
		desc = "Toggle [c]onceal",
	},
	{
		"<leader>z",
		function()
			Snacks.zen()
		end,
		desc = "Toggle [z]en mode",
	},
	{
		"<leader>Z",
		function()
			Snacks.zen.zoom()
		end,
		desc = "Toggle [Z]oom",
	},
	{
		"<leader>.",
		function()
			Snacks.scratch()
		end,
		desc = "Toggle scratch buffer [.]",
	},
	{
		"<leader>S",
		function()
			Snacks.scratch.select()
		end,
		desc = "[S]elect scratch buffer",
	},
	{
		"<leader>x",
		function()
			Snacks.bufdelete()
		end,
		desc = "Close buffer [x]",
	},
	{
		"<leader>cR",
		function()
			Snacks.rename.rename_file()
		end,
		desc = "Rename file [R]",
	},
	{
		"]]",
		function()
			Snacks.words.jump(vim.v.count1)
		end,
		desc = "Next reference []]",
		mode = { "n", "t" },
	},
	{
		"[[",
		function()
			Snacks.words.jump(-vim.v.count1)
		end,
		desc = "Prev reference [[[]",
		mode = { "n", "t" },
	},
}
for _, key in ipairs(snacks_keys) do
	local mode = key.mode or "n"
	vim.keymap.set(mode, key[1], key[2], { desc = key.desc, nowait = key.nowait })
end

-- [[ JUST ]] -----------------------------------------------------------------

-- Starts in Normal mode so output can be yanked; <Esc><Esc> leaves (snacks
-- terminal convention). The t-mode map is buffer-local.
local function just_term(recipe)
	vim.cmd("terminal just" .. (recipe and recipe ~= "" and " " .. recipe or ""))
	vim.cmd("stopinsert")
	vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { buffer = vim.api.nvim_get_current_buf() })
end
vim.keymap.set("n", "<leader>jj", function()
	just_term()
end, { desc = "[j]ust (default recipe)" })
vim.keymap.set("n", "<leader>jr", function()
	just_term("run")
end, { desc = "[j]ust [r]un" })
vim.keymap.set("n", "<leader>jc", function()
	just_term("check")
end, { desc = "[j]ust [c]heck" })
vim.keymap.set("n", "<leader>jt", function()
	just_term("test")
end, { desc = "[j]ust [t]est" })
vim.keymap.set("n", "<leader>ji", function()
	just_term("ci")
end, { desc = "[j]ust c[i]" })

-- [[ MARKDOWN ]] -------------------------------------------------------------

require("render-markdown").setup({
	latex = { enabled = false },
})

-- [[ TREESITTER ]] -----------------------------------------------------------

-- v1: highlight and indent are automatic, no nvim-treesitter.configs.
require("nvim-treesitter").setup({})
require("nvim-treesitter").install({
	-- Core & Web
	"html",
	"css",
	"scss",
	"javascript",
	"typescript",
	"tsx",
	"vue",
	"svelte",
	"astro",
	-- Systems & Languages
	"rust",
	"go",
	"zig",
	"python",
	"c",
	"cpp",
	"bash",
	"sql",
	"proto",
	-- Data & Docs
	"json",
	"toml",
	"yaml",
	"dockerfile",
	"regex",
	"latex",
	"typst",
})

-- [[ COLORIZER ]] ------------------------------------------------------------

require("colorizer").setup({
	user_default_options = {
		mode = "background",
		rgb = true,
		rrggbb = true,
		rrggbbaa = true,
	},
})

-- rainbow-delimiters needs no setup(): the plugin/ file loaded by vim.pack.add
-- is enough and colors come from the theme.

-- [[ COMPLETION ]] -----------------------------------------------------------

-- fuzzy = "lua" avoids the Rust binary.
require("blink.cmp").setup({
	keymap = { preset = "default" },
	appearance = { nerd_font_variant = "mono" },
	completion = { documentation = { auto_show = false, auto_show_delay_ms = 500 } },
	sources = {
		default = { "lsp", "path", "snippets", "lazydev" },
		providers = {
			lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
		},
	},
	fuzzy = { implementation = "lua" },
	signature = { enabled = true },
})

-- [[ FORMAT ]] ---------------------------------------------------------------

-- markdown goes through the linter in --fix mode; taplo's binary comes from the
-- taplo LSP package, hence the extra args.
require("conform").setup({
	notify_on_error = false,
	formatters_by_ft = {
		lua = { "stylua" },
		javascript = { "oxfmt" },
		typescript = { "oxfmt" },
		javascriptreact = { "oxfmt" },
		typescriptreact = { "oxfmt" },
		json = { "oxfmt" },
		css = { "oxfmt" },
		scss = { "oxfmt" },
		html = { "oxfmt" },
		astro = { "oxfmt" },
		svelte = { "oxfmt" },
		vue = { "oxfmt" },
		sh = { "shfmt" },
		bash = { "shfmt" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		sql = { "sql_formatter" },
		toml = { "taplo" },
		yaml = { "yamlfmt" },
		markdown = { "markdownlint-cli2" },
		proto = { "buf" },
	},
	formatters = {
		taplo = {
			append_args = { "-o", "array_auto_collapse=false" },
		},
	},
})
vim.keymap.set({ "n", "v" }, "<leader>f", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "[f]ormat buffer" })
-- Sync on purpose: the write must happen after formatting completes.
vim.keymap.set({ "n", "i", "x" }, "<C-s>", function()
	require("conform").format({
		async = false,
		lsp_format = "fallback",
	}, function()
		vim.cmd("w")
	end)
end, { desc = "Format and Save" })

-- [[ LINT ]] -----------------------------------------------------------------

-- No alphabetization requirement for env files.
require("lint").linters.dotenv_linter.args = { "check", "--quiet", "--ignore-checks", "UnorderedKey" }
require("lint").linters_by_ft = {
	javascript = { "oxlint" },
	typescript = { "oxlint" },
	javascriptreact = { "oxlint" },
	typescriptreact = { "oxlint" },
	sh = { "shellcheck" },
	env = { "dotenv_linter" },
	markdown = { "markdownlint-cli2" },
	go = { "golangcilint" },
}
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
	group = vim.api.nvim_create_augroup("lint", { clear = true }),
	callback = function()
		if vim.bo.modifiable then
			require("lint").try_lint()
		end
	end,
})

-- [[ GIT ]] ------------------------------------------------------------------

require("gitsigns").setup({
	signs = {
		add = { text = "+" },
		change = { text = "~" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
	},
	on_attach = function(bufnr)
		local gitsigns = require("gitsigns")
		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end
		map("n", "]c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]c", bang = true })
			else
				gitsigns.nav_hunk("next")
			end
		end, { desc = "Jump to next git [c]hange" })
		map("n", "[c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[c", bang = true })
			else
				gitsigns.nav_hunk("prev")
			end
		end, { desc = "Jump to previous git [c]hange" })
		map("v", "<leader>hs", function()
			gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "git [s]tage hunk" })
		map("v", "<leader>hr", function()
			gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "git [r]eset hunk" })
		map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "git [s]tage hunk" })
		map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "git [r]eset hunk" })
		map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "git [S]tage buffer" })
		-- stage_hunk() toggles on staged signs, so it cannot undo a stage.
		---@diagnostic disable-next-line: deprecated
		map("n", "<leader>hu", gitsigns.undo_stage_hunk, { desc = "git [u]ndo stage hunk" })
		map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "git [R]eset buffer" })
		map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "git [p]review hunk" })
		map("n", "<leader>hb", gitsigns.blame_line, { desc = "git [b]lame line" })
		map("n", "<leader>hd", gitsigns.diffthis, { desc = "git [d]iff against index" })
		map("n", "<leader>hD", function()
			gitsigns.diffthis("@")
		end, { desc = "git [D]iff against last commit" })
		map("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "[T]oggle git show [b]lame line" })
		map("n", "<leader>tD", gitsigns.preview_hunk_inline, { desc = "[T]oggle git show [D]eleted" })
	end,
})

-- [[ WHICH-KEY ]] ------------------------------------------------------------

-- spec only declares group labels; descriptions come from each keymap's desc.
require("which-key").setup({
	delay = 0,
	icons = {
		mappings = vim.g.have_nerd_font,
		keys = vim.g.have_nerd_font and {} or {
			Up = "<Up> ",
			Down = "<Down> ",
			Left = "<Left> ",
			Right = "<Right> ",
			C = "<C-…> ",
			M = "<M-…> ",
			D = "<D-…> ",
			S = "<S-…> ",
			CR = "<CR> ",
			Esc = "<Esc> ",
			ScrollWheelDown = "<ScrollWheelDown> ",
			ScrollWheelUp = "<ScrollWheelUp> ",
			NL = "<NL> ",
			BS = "<BS> ",
			Space = "<Space> ",
			Tab = "<Tab> ",
			F1 = "<F1>",
			F2 = "<F2>",
			F3 = "<F3>",
			F4 = "<F4>",
			F5 = "<F5>",
			F6 = "<F6>",
			F7 = "<F7>",
			F8 = "<F8>",
			F9 = "<F9>",
			F10 = "<F10>",
			F11 = "<F11>",
			F12 = "<F12>",
		},
	},
	spec = {
		{ "<leader>s", group = "[s]earch" },
		{ "<leader>t", group = "[t]oggle" },
		{ "<leader>d", group = "[d]ebug" },
		{ "<leader>h", group = "Git [h]unk", mode = { "n", "v" } },
		{ "<leader>g", group = "[g]it" },
		{ "<leader>j", group = "[j]ust" },
		{ "<leader>m", group = "[m]ark file slot" },
		{ "<leader>f", desc = "[f]ormat" },
		{ "<leader>q", desc = "[q]uickfix" },
		{ "g", group = "[g]oto / LSP" },
		{ "gr", group = "[r]ename / Ref" },
	},
})

-- [[ LAZYDEV ]] --------------------------------------------------------------

require("lazydev").setup({
	library = {
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
	},
})

-- [[ AUTOPAIRS ]] ------------------------------------------------------------

require("nvim-autopairs").setup({})

-- [[ TODO-COMMENTS ]] --------------------------------------------------------

-- <leader>st / <leader>sT drive :TodoQuickFix; search needs plenary.
require("todo-comments").setup({})

-- [[ LSP ]] ------------------------------------------------------------------

-- ty emits hint-level notes that duplicate real diagnostics; filter them out.
local original_diagnostic_set = vim.diagnostic.set
---@diagnostic disable-next-line: duplicate-set-field
vim.diagnostic.set = function(ns, bufnr, diagnostics, opts)
	local filtered = vim.tbl_filter(function(d)
		return not (d.source == "ty" and d.severity == vim.diagnostic.severity.HINT)
	end, diagnostics)
	original_diagnostic_set(ns, bufnr, filtered, opts)
end

-- goto/refs are global snacks maps (gd, gD, grr, gI, gy); only per-buffer maps here.
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
	callback = function(event)
		local map = function(keys, func, desc, mode)
			mode = mode or "n"
			vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end
		map("gra", vim.lsp.buf.code_action, "[g]oto code [a]ction", { "n", "x" })
		map("grD", vim.lsp.buf.declaration, "[g]oto [D]eclaration")
	end,
})
vim.diagnostic.config({
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = vim.diagnostic.severity.ERROR },
	signs = vim.g.have_nerd_font and {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚 ",
			[vim.diagnostic.severity.WARN] = "󰀪 ",
			[vim.diagnostic.severity.INFO] = "󰋽 ",
			[vim.diagnostic.severity.HINT] = "󰌶 ",
		},
	} or {},
	virtual_text = { source = "if_many", spacing = 2 },
})

-- mason-lspconfig installs and enables these (automatic_enable), so no
-- vim.lsp.enable() call is needed. Capabilities are merged from blink below.
local servers = {
	["bashls"] = {},
	["clangd"] = {},
	["jsonls"] = {},
	["vtsls"] = {
		settings = {
			vtsls = {
				tsserver = {
					globalPlugins = {
						{
							name = "@vue/typescript-plugin",
							location = vim.fn.stdpath("data")
								.. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
							languages = { "vue" },
							configNamespace = "typescript",
							enableForWorkspaceTypeScriptVersions = true,
						},
					},
				},
			},
		},
		filetypes = {
			"typescript",
			"javascript",
			"javascriptreact",
			"typescriptreact",
			"vue",
		},
	},
	["dockerls"] = {},
	["yamlls"] = {},
	["cssls"] = {},
	["emmet_language_server"] = {},
	["fish_lsp"] = {},
	["just"] = {},
	["rust_analyzer"] = {
		settings = {
			["rust-analyzer"] = {
				check = { command = "clippy" },
			},
		},
	},
	["ruff"] = { init_options = { settings = { lineLength = 120 } } },
	["ty"] = {},
	["lua_ls"] = {
		settings = {
			Lua = {
				completion = { callSnippet = "Replace" },
				workspace = { checkThirdParty = false },
				diagnostics = { globals = { "vim" } },
			},
		},
	},
	["gopls"] = {
		settings = {
			gopls = {
				analyses = {
					nilness = true,
					unusedparams = true,
					unusedwrite = true,
					shadow = false,
				},
				staticcheck = true,
			},
		},
	},
	["vue_ls"] = {},
	["zls"] = {
		settings = {
			enable_build_on_save = true,
		},
	},
	["taplo"] = {},
	["marksman"] = {},
	["mesonlsp"] = {},
	["cmake"] = {},
}

for name, config in pairs(servers) do
	config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
	vim.lsp.config(name, config)
end

require("mason-lspconfig").setup({
	ensure_installed = vim.tbl_keys(servers),
	automatic_enable = true,
})

-- [[ DAP ]] ------------------------------------------------------------------

require("dap-view").setup()
local dap_python = require("dap-python")
dap_python.setup(vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python")
local dap = require("dap")
local dap_view = require("dap-view")
vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Debug: Set Conditional Breakpoint" })
vim.keymap.set("n", "<leader>dv", dap_view.toggle, { desc = "Debug: Toggle View" })
vim.keymap.set("n", "<leader>dx", dap.terminate, { desc = "Debug: Terminate/Exit" })

table.insert(dap.configurations.python, {
	type = "python",
	request = "launch",
	name = "module",
	module = function()
		return vim.fn.input("Module: ")
	end,
	console = "integratedTerminal",
})
table.insert(dap.configurations.python, {
	type = "python",
	request = "launch",
	name = "pytest: file",
	module = "pytest",
	args = { "${file}" },
	console = "integratedTerminal",
})
table.insert(dap.configurations.python, {
	type = "python",
	request = "attach",
	name = "attach: pick process",
	processId = require("dap.utils").pick_process,
})
vim.keymap.set({ "n", "v" }, "<leader>dm", dap_python.test_method, { desc = "Debug: test [m]ethod" })
vim.keymap.set({ "n", "v" }, "<leader>dC", dap_python.test_class, { desc = "Debug: test [C]lass" })

-- Listener keys are arbitrary but unique per event.
dap.listeners.after.event_initialized["dap_view_config"] = function()
	dap_view.open()
end
dap.listeners.after.event_initialized["dap_exception_config"] = function()
	dap.set_exception_breakpoints({ "uncaught" })
end

-- Go: delve speaks DAP over a socket; ${port} is expanded by nvim-dap.
dap.adapters.go = {
	type = "server",
	port = "${port}",
	executable = {
		command = "dlv",
		args = { "dap", "-l", "127.0.0.1:${port}" },
	},
}
dap.configurations.go = {
	{
		type = "go",
		name = "Debug File",
		request = "launch",
		program = "${file}",
		dlvToolPath = vim.fn.exepath("dlv"),
	},
	{
		type = "go",
		name = "Debug Package",
		request = "launch",
		program = "${fileDirname}",
		dlvToolPath = vim.fn.exepath("dlv"),
	},
	{
		type = "go",
		name = "Debug Package Tests",
		request = "launch",
		mode = "test",
		program = "${fileDirname}",
		dlvToolPath = vim.fn.exepath("dlv"),
	},
	{
		type = "go",
		name = "Debug Test Function",
		request = "launch",
		mode = "test",
		program = "${fileDirname}",
		args = function()
			return { "-test.run", vim.fn.input("Test function (regex): ", "^" .. vim.fn.expand("<cword>") .. "$") }
		end,
		dlvToolPath = vim.fn.exepath("dlv"),
	},
}

-- Rust and Zig share the lldb-dap adapter table; only configurations differ.
dap.adapters.rust = {
	type = "executable",
	command = "lldb-dap",
	name = "lldb",
}
dap.adapters.zig = dap.adapters.rust
dap.configurations.rust = {
	{
		name = "Launch",
		type = "rust",
		request = "launch",
		program = function()
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		args = {},
	},
}
dap.configurations.zig = {
	{
		name = "Launch",
		type = "zig",
		request = "launch",
		program = function()
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/zig-out/bin/", "file")
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		args = {},
	},
}
vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "▶️", texthl = "", linehl = "", numhl = "" })

-- [[ UI ]] -------------------------------------------------------------------

-- NVIM_THEME picks the colorscheme; NVIM_OLED=1 forces a black Normal background.
local oled = vim.env.NVIM_OLED == "1"
local theme = vim.env.NVIM_THEME or "tokyonight"
if not pcall(vim.cmd.colorscheme, theme) then
	vim.notify("Failed to load theme: " .. theme, vim.log.levels.WARN)
end
if oled then
	vim.api.nvim_set_hl(0, "Normal", { bg = "#000000" })
end

-- %S renders showcmd/showcmdloc; macro_recording() restores what cmdheight=0
-- hides. theme = "auto" resolves against the colorscheme loaded above.
local function macro_recording()
	local reg = vim.fn.reg_recording()
	if reg == "" then
		return ""
	end
	return "rec @" .. reg
end
require("lualine").setup({
	options = {
		theme = "auto",
		globalstatus = true,
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = { "filename" },
		lualine_x = { "%S", macro_recording, "filetype" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
})

-- Insert/visual variants drop to Normal first: <Cmd> preserves the mode.
vim.keymap.set({ "n", "t" }, "<C-Tab>", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set({ "n", "t" }, "<C-S-Tab>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("i", "<C-Tab>", "<C-\\><C-n><cmd>bnext<CR>", { desc = "Next buffer (from insert)" })
vim.keymap.set("i", "<C-S-Tab>", "<C-\\><C-n><cmd>bprevious<CR>", { desc = "Previous buffer (from insert)" })
vim.keymap.set("v", "<C-Tab>", "<Esc><cmd>bnext<CR>", { desc = "Next buffer (from visual)" })
vim.keymap.set("v", "<C-S-Tab>", "<Esc><cmd>bprevious<CR>", { desc = "Previous buffer (from visual)" })
