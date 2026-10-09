return {
	--  "catppuccin/nvim",
	--  name = "catppuccin",
	-- "rose-pine/neovim",
	-- name = "rose-pine",
	-- "ellisonleao/gruvbox.nvim",
	-- name = "gruvbox",
	-- "rebelot/kanagawa.nvim",
	-- name = "kanagawa",
	-- Sublime Text's default Monokai
	"tanvirtin/monokai.nvim",
	name = "monokai",
	priority = 1000,
	config = function()
		-- vim.cmd("colorscheme gruvbox")
		local monokai = require("monokai")
		-- Sublime's exact background/selection colours
		local palette = vim.tbl_extend("force", monokai.classic, {
			base2 = "#272822",
			base3 = "#3e3d32",
		})
		monokai.setup({ palette = palette })
	end,
}

-- return {
-- 	"AlphaTechnolog/pywal.nvim",
-- 	lazy = false,
-- 	priority = 1000,
-- 	config = function()
-- 		-- Set up pywal and load the colors
-- 		require("pywal").setup()
-- 	end,
-- }
