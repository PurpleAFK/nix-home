local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({ { import = "purple.plugins" }, { import = "purple.plugins.lsp" } }, {
	checker = {
		enabled = true,
		notify = false,
	},
	change_detection = {
		notify = false,
	},
})

vim.diagnostic.config({
	signs = {
		active = true,
		-- Configure the signs you want to use
		-- This overrides any deprecated settings from other plugins
		severity = {
			min = vim.diagnostic.severity.HINT,
		},
		-- Define the appearance of the signs
		text = {
			[vim.diagnostic.severity.ERROR] = "", -- Error icon
			[vim.diagnostic.severity.WARN] = "", -- Warning icon
			[vim.diagnostic.severity.INFO] = "", -- Info icon
			[vim.diagnostic.severity.HINT] = "", -- Hint icon
		},
		-- You can also configure line highlights here if desired
		line_hl = false,
	},
})
