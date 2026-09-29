vim.g.mapleader = " "

local keymap = vim.keymap

keymap.set("i", "kj", "<ESC>", { desc = "Exit insert mode with kj" })
keymap.set("i", "<C-h>", "<C-w>", { desc = "Delete previous word (Ctrl+Backspace/C-h)" })
keymap.set("i", "<C-BS>", "<C-w>", { desc = "Delete previous word (Ctrl+Backspace/C-BS)" })
vim.keymap.set("n", "<leader>cl", ":nohl<CR>", { desc = "Clear seach highlights" })
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save the file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit without saving" })

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

-- contests
vim.keymap.set("n", "<leader>t", function()
	vim.cmd("write")
	if test_buf and vim.api.nvim_buf_is_valid(test_buf) then
		vim.api.nvim_buf_delete(test_buf, { force = true })
	end
	vim.cmd("vsplit | terminal " .. vim.fn.expand("$HOME") .. "/cf-contests/scripts/test.sh")
	vim.cmd("vertical resize 50")
	test_buf = vim.api.nvim_get_current_buf()
	vim.cmd("startinsert")
end)

vim.keymap.set("n", "<leader>s", "<cmd>%y+<cr>", { desc = "Copy to clipboard" })

-- Quick close the terminal pane: press q in normal mode
vim.api.nvim_create_autocmd("TermOpen", {
	callback = function()
		local opts = { buffer = true, silent = true }
		vim.keymap.set("n", "q", "<cmd>bd!<cr>", opts)
	end,
})

-- obsidian.nvim
vim.keymap.set("n", "<leader>np", function()
	-- Ensure obsidian is loaded
	require("obsidian")

	local title = vim.fn.input("Note title: ")
	if title == "" or title == nil then
		print(" Note creation cancelled")
		return
	end

	vim.cmd("ObsidianNew permanent/" .. title)

	vim.defer_fn(function()
		local lines = {
			"---",
			"title: " .. title,
			"created: " .. os.date("%a-%d-%m-%Y %H:%M"),
			"tags:",
			"  - permanent",
			"type: permanent",
			"---",
			"# " .. title,
			"",
			"## Main Idea",
			"",
			"## Elaboration",
			"",
			"## Connections",
			"",
			"## References",
			"---",
		}
		vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
		vim.api.nvim_win_set_cursor(0, { 10, 0 })
	end, 100)
end, { desc = "New Zettelkasten note" })

vim.keymap.set("n", "<leader>nr", function()
	require("obsidian")

	local title = vim.fn.input("Note title: ")
	if title == "" or title == nil then
		print(" Note creation cancelled")
		return
	end

	vim.cmd("ObsidianNew resources/" .. title)

	vim.defer_fn(function()
		local lines = {
			"---",
			"title: " .. title,
			"created: " .. os.date("%a-%d-%m-%Y %H:%M"),
			"tags:",
			"  - ",
			"type: resource",
			"---",
			"# " .. title,
			"",
			"## Source Information",
			"",
			"## Related Permanent Notes",
			"",
			"---",
		}
		vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
		vim.api.nvim_win_set_cursor(0, { 10, 0 })
	end, 100)
end, { desc = "New Resource note" })

vim.keymap.set("n", "<leader>nf", function()
	require("obsidian")

	local title = vim.fn.input("Note title: ")
	if title == "" or title == nil then
		print(" Note creation cancelled")
		return
	end

	vim.cmd("ObsidianNew inbox/" .. title)

	vim.defer_fn(function()
		local lines = {
			"---",
			"title: " .. title,
			"created: " .. os.date("%a-%d-%m-%Y %H:%M"),
			"tags:",
			"  - ",
			"type: fleeting",
			"---",
			"# " .. title,
			"",
			"## Quick Capture",
			"",
			"---",
			"**Process by:**",
		}
		vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
		vim.api.nvim_win_set_cursor(0, { 10, 0 })
	end, 100)
end, { desc = "New Fleeting note" })

-- Daily note keybind
vim.keymap.set("n", "<leader>nd", function()
	require("obsidian")

	local date = os.date("%a-%d-%m-%Y")
	local filename = os.date("%Y-%m-%d")

	vim.cmd("ObsidianNew daily/" .. filename)

	vim.defer_fn(function()
		local lines = {
			"---",
			"date: " .. date,
			"tags:",
			"  - daily",
			"type: daily",
			"---",
			"",
			"# " .. date,
			"",
			"## Tasks",
			"- [ ] ",
			"",
			"## Notes",
			"",
			"",
			"## Reflections",
			"",
			"",
			"---",
		}
		vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
		vim.api.nvim_win_set_cursor(0, { 11, 6 }) -- Cursor after first task checkbox
	end, 100)
end, { desc = "Open today's daily note" })

-- todofloat
vim.keymap.set("n", "<leader>td", ":Td<CR>", { desc = "Open the floating todo list" })
