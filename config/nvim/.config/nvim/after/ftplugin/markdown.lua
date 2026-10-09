local notes = require("purple.notes")

-- Fold by heading sections (treesitter)
vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt_local.foldtext = ""
vim.opt_local.foldlevel = 99
vim.opt_local.fillchars:append({ fold = " " })

local function map(mode, lhs, rhs, desc, opts)
	vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { buffer = true, desc = desc }, opts or {}))
end

-- Folding
map("n", "<CR>", notes.enter, "Toggle heading fold", { expr = true })
map("n", "zj", notes.fold_level(0), "Fold all headings")
map("n", "zk", notes.fold_level(1), "Fold level 2+ headings")
map("n", "zl", notes.fold_level(2), "Fold level 3+ headings")
map("n", "zu", notes.fold_level(99), "Unfold everything")

-- Tasks
map("n", "<leader>mx", notes.toggle_task, "Toggle task checkbox")
map({ "n", "i" }, "<M-x>", notes.complete_task, "Complete task and move to Completed")
map("n", "<leader>mt", function()
	notes.list_tasks(false)
end, "Open tasks")
map("n", "<leader>mc", function()
	notes.list_tasks(true)
end, "Completed tasks")

-- Highlight (==text==)
map("x", "<leader>mh", notes.toggle_highlight, "Toggle ==highlight== on selection")
