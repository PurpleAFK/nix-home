return {
	"lervag/vimtex",
	lazy = false, -- Recommended by author
	init = function()
		vim.g.vimtex_view_method = "zathura"
		-- This ensures SyncTeX works (Zathura -> Nvim)
		vim.g.vimtex_view_zathura_options = '-x "nvim --remote +%l %f"'
		-- Syntax highlighting
		vim.g.vimtex_syntax_enabled = 1
	end,
}
