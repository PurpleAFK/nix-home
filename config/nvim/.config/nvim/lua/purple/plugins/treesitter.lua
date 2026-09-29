return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		-- Use pcall to avoid the 'module not found' crash during installation
		local status, treesitter = pcall(require, "nvim-treesitter.configs")
		if not status then
			return
		end

		treesitter.setup({
			highlight = {
				enable = true,
				-- IMPORTANT: Disable treesitter for latex to let VimTeX handle it
				-- Treesitter latex highlighting is known to break VimTeX features
				disable = { "latex" },
			},
			indent = { enable = true },
			autotag = { enable = true },
			ensure_installed = {
				"json",
				"javascript",
				"typescript",
				"yaml",
				"html",
				"css",
				"markdown",
				"markdown_inline",
				"bash",
				"lua",
				"c",
				"cpp",
				"vim",
				"query",
				"vimdoc",
				"latex", -- Add latex here for better indentation/folding
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
		})
	end,
}
