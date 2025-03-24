if vim.g.did_load_keymaps_plugin then
	return
end
vim.g.did_load_keymaps_plugin = true

local api = vim.api
local fn = vim.fn
local keymap = vim.keymap
local diagnostic = vim.diagnostic

-- Toggle the quickfix list (only opens if it is populated)
local function toggle_qf_list()
	local qf_exists = false
	for _, win in pairs(fn.getwininfo() or {}) do
		if win["quickfix"] == 1 then
			qf_exists = true
		end
	end
	if qf_exists == true then
		vim.cmd.cclose()
		return
	end
	if not vim.tbl_isempty(vim.fn.getqflist()) then
		vim.cmd.copen()
	end
end

local function try_fallback_notify(opts)
	local success, _ = pcall(opts.try)
	if success then
		return
	end
	success, _ = pcall(opts.fallback)
	if success then
		return
	end
	vim.notify(opts.notify, vim.log.levels.INFO)
end

-- move between splits
keymap.set("n", "<C-h>", "<C-w>h")
keymap.set("n", "<C-j>", "<C-w>j")
keymap.set("n", "<C-k>", "<C-w>k")
keymap.set("n", "<C-l>", "<C-w>l")

local severity = diagnostic.severity

keymap.set("n", "<space>e", function()
	local _, winid = diagnostic.open_float(nil, { scope = "line" })
	if not winid then
		vim.notify("no diagnostics found", vim.log.levels.INFO)
		return
	end
	vim.api.nvim_win_set_config(winid or 0, { focusable = true })
end, { noremap = true, silent = true, desc = "diagnostics floating window" })
keymap.set("n", "[e", function()
	diagnostic.goto_prev({
		severity = severity.ERROR,
	})
end, { noremap = true, silent = true, desc = "previous [e]rror diagnostic" })
keymap.set("n", "]e", function()
	diagnostic.goto_next({
		severity = severity.ERROR,
	})
end, { noremap = true, silent = true, desc = "next [e]rror diagnostic" })
keymap.set("n", "[w", function()
	diagnostic.goto_prev({
		severity = severity.WARN,
	})
end, { noremap = true, silent = true, desc = "previous [w]arning diagnostic" })
keymap.set("n", "]w", function()
	diagnostic.goto_next({
		severity = severity.WARN,
	})
end, { noremap = true, silent = true, desc = "next [w]arning diagnostic" })
keymap.set("n", "[h", function()
	diagnostic.goto_prev({
		severity = severity.HINT,
	})
end, { noremap = true, silent = true, desc = "previous [h]int diagnostic" })
keymap.set("n", "]h", function()
	diagnostic.goto_next({
		severity = severity.HINT,
	})
end, { noremap = true, silent = true, desc = "next [h]int diagnostic" })

-- Location list and jumplist operations
keymap.set("n", "<leader>l", function()
	require("utils").toggle_ll()
end, { silent = true, desc = "Toggle location list" })

keymap.set("n", "<leader><C-o>", function()
	require("utils").jumps_to_qf()
end, { silent = true, desc = "Send jumplist to quickfix" })
