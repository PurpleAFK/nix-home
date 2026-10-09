-- Note-taking extras (inspired by linkarzu's "Why I Replaced Obsidian with Neovim")
local vault = vim.fn.expand("~/convergence")

return {
	-- Inline images in markdown (kitty graphics protocol)
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			image = {
				enabled = true,
				doc = { inline = true, float = true, max_width = 80, max_height = 30 },
				math = { enabled = false }, -- vimtex handles math
				-- obsidian.nvim pastes into the vault-level _attachments folder,
				-- so fall back to the vault root when the path isn't relative to the note
				resolve = function(file, src)
					if not vim.startswith(file, vault) then
						return nil
					end
					for _, candidate in ipairs({ vault .. "/" .. src, vault .. "/_attachments/" .. src }) do
						if vim.uv.fs_stat(candidate) then
							return candidate
						end
					end
				end,
			},
		},
	},

	-- Heading outline sidebar
	{
		"hedyhli/outline.nvim",
		cmd = { "Outline", "OutlineOpen" },
		keys = {
			{ "<leader>mo", "<cmd>Outline<cr>", desc = "Toggle outline" },
		},
		opts = {
			outline_window = { position = "right", width = 25 },
		},
	},

	-- Browser preview (tables wrap properly, print to PDF)
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
		ft = { "markdown" },
		build = function()
			require("lazy").load({ plugins = { "markdown-preview.nvim" } })
			vim.fn["mkdp#util#install"]()
		end,
		init = function()
			vim.g.mkdp_theme = "dark"
			vim.g.mkdp_auto_close = 0
		end,
		keys = {
			{ "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "Markdown preview" },
		},
	},
}
