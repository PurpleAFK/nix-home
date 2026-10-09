-- nvim-treesitter `main` branch: no more `nvim-treesitter.configs`.
-- Parsers are installed via `install()`, highlighting is started per-buffer.
return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	-- last commit supporting Nvim 0.11 (c82bf96f dropped it); unpin after upgrading to 0.12
	commit = "90cd6580e720caedacb91fdd587b747a6e77d61f",
	lazy = false,
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		local parsers = {
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
			"latex",
		}
		require("nvim-treesitter").install(parsers)

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("purple_treesitter", { clear = true }),
			callback = function(args)
				-- VimTeX handles latex highlighting; treesitter breaks its features
				if args.match == "tex" or args.match == "latex" then
					return
				end
				if not pcall(vim.treesitter.start, args.buf) then
					return
				end
				vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})

		require("nvim-ts-autotag").setup()
	end,
}
