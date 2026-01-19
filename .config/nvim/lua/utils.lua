local M = {}

function M.pycheck()
	-- Use concise for both for consistent parsing
	local ruff = vim.system({ "ruff", "check", "--output-format=concise" }, { text = true }):wait()
	local ty = vim.system({ "ty", "check", "--output-format=concise" }, { text = true }):wait()

	local raw_output = (ruff.stdout or "") .. "\n" .. (ty.stdout or "")
	local data = {}

	for _, line in ipairs(vim.split(raw_output, "\n")) do
		-- Pattern: filename:line:col: message
		local fname, lnum, col = line:match("^([^:]+):(%d+):(%d+):")

		if fname and not fname:match("Found %d+ diagnostics") then
			lnum, col = tonumber(lnum), tonumber(col)

			if not data[fname] then
				data[fname] = { lnum = lnum, col = col, count = 1 }
			else
				data[fname].count = data[fname].count + 1
				-- Update to find the earliest issue in the file
				if lnum < data[fname].lnum or (lnum == data[fname].lnum and col < data[fname].col) then
					data[fname].lnum = lnum
					data[fname].col = col
				end
			end
		end
	end

	local qf_items = {}
	for fname, info in pairs(data) do
		table.insert(qf_items, {
			filename = fname,
			lnum = info.lnum,
			col = info.col,
			text = string.format("%d issues", info.count),
			valid = 1,
		})
	end

	if #qf_items == 0 then
		print("All checks passed!")
		vim.fn.setqflist({}, "r") -- Clear the old errors
		vim.cmd("cclose") -- Close the quickfix window if it's open
		return
	end

	-- Sort files alphabetically
	table.sort(qf_items, function(a, b)
		return a.filename < b.filename
	end)

	vim.fn.setqflist(qf_items, "r")
	vim.fn.setqflist({}, "a", { title = "Python Check" })

	-- Open Quickfix and jump to the specific line/col of the first file
	vim.cmd("copen")
	vim.cmd("cc 1")
end

function M.random_dark_theme()
	local schemes = vim.fn.getcompletion("", "color")

	local skip = {
		"zellner",
		"tokyonight-day",
		"shine",
		"rose-pine-dawn",
		"peachpuff",
		"morning",
		"miniwinter",
		"minisummer",
		"minispring",
		"minischeme",
		"minicyan",
		"miniautumn",
		"lunaperche",
		"kanagawa-lotus",
		"delek",
		"default",
		"catppuccin-latte",
	}

	local candidates = {}
	for _, s in ipairs(schemes) do
		local should_skip = false
		for _, name in ipairs(skip) do
			if s == name then
				should_skip = true
				break
			end
		end

		if not should_skip then
			table.insert(candidates, s)
		end
	end

	if #candidates == 0 then
		return
	end

	math.randomseed(os.clock() * 1000000)
	local theme = candidates[math.random(#candidates)]

	local ok, err = pcall(vim.cmd.colorscheme, theme)
	if not ok then
		vim.notify("Error loading " .. theme .. ": " .. err, vim.log.levels.ERROR)
	end
end

return M
