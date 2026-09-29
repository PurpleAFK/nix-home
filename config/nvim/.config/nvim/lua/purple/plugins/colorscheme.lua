return {
	--  "catppuccin/nvim",
	--  name = "catppuccin",
	-- "rose-pine/neovim",
	-- name = "rose-pine",
	-- "ellisonleao/gruvbox.nvim",
	-- name = "gruvbox",
	"rebelot/kanagawa.nvim",
	name = "kanagawa",
	priority = 1000,
	config = function()
		vim.cmd("colorscheme kanagawa")
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
