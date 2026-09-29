return {
	"hrsh7th/nvim-cmp",
	event = "InsertEnter",
	dependencies = {
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-nvim-lsp",
		"jc-doyle/cmp-pandoc-references",
		{
			"L3MON4D3/LuaSnip",
			version = "v2.*",
			build = "make install_jsregexp",
		},
		"saadparwaiz1/cmp_luasnip",
		"rafamadriz/friendly-snippets",
		"onsails/lspkind.nvim",
	},
	config = function()
		-- Remove Neovim's built-in 0.11+ default Tab/S-Tab mappings
		-- (vim.snippet.jump) BEFORE cmp sets its own, so cmp's mapping
		-- is the one left active.
		pcall(vim.keymap.del, { "i", "s" }, "<Tab>")
		pcall(vim.keymap.del, { "i", "s" }, "<S-Tab>")
		local cmp = require("cmp")
		local luasnip = require("luasnip")
		local lspkind = require("lspkind")

		require("luasnip.loaders.from_vscode").lazy_load()
		require("luasnip.loaders.from_vscode").lazy_load({
			paths = { vim.fn.stdpath("config") .. "/snippets" },
		})
		require("luasnip.loaders.from_lua").lazy_load({
			paths = { vim.fn.stdpath("config") .. "/lua/purple/snippets" },
		})

		luasnip.config.set_config({
			history = true,
			updateevents = "TextChanged,TextChangedI",
			enable_autosnippets = true,
			region_check_events = "CursorMoved,CursorMovedI,InsertEnter",
			delete_check_events = "TextChanged,InsertLeave",
		})

		local kind_menu = {
			nvim_lsp = "[LSP]",
			luasnip = "[Snip]",
			buffer = "[Buf]",
			path = "[Path]",
			obsidian = "[Vault]",
			obsidian_new = "[Vault+]",
			obsidian_tags = "[Tag]",
			pandoc_references = "[Cite]",
		}

		cmp.setup({
			completion = {
				completeopt = "menu,menuone,preview,noselect",
			},
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-k>"] = cmp.mapping.select_prev_item(),
				["<C-j>"] = cmp.mapping.select_next_item(),
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-e>"] = cmp.mapping.abort(),
				["<CR>"] = cmp.mapping.confirm({ select = false }),
				["<Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					elseif luasnip.expand_or_jumpable() then
						luasnip.expand_or_jump()
					else
						fallback()
					end
				end, { "i", "s" }),
				["<S-Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					elseif luasnip.jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end, { "i", "s" }),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp", priority = 1000 },
				{ name = "luasnip", priority = 750 },
				{ name = "path", priority = 500 },
				{ name = "buffer", priority = 250, keyword_length = 3 },
			}),
			formatting = {
				format = lspkind.cmp_format({
					maxwidth = 50,
					ellipsis_char = "...",
					menu = kind_menu,
				}),
			},
		})

		-- Markdown (vault notes): vault sources first, then citations, snippets, path, buffer.
		cmp.setup.filetype("markdown", {
			sources = cmp.config.sources({
				{ name = "obsidian", priority = 1000 },
				{ name = "obsidian_new", priority = 900 },
				{ name = "obsidian_tags", priority = 800 },
				{ name = "pandoc_references", priority = 700 },
				{ name = "luasnip", priority = 600 },
				{ name = "path", priority = 500 },
				{ name = "buffer", priority = 250, keyword_length = 3 },
			}),
		})

		-- LaTeX: keep snippets hot, add citation source, drop vault noise.
		cmp.setup.filetype({ "tex", "plaintex" }, {
			sources = cmp.config.sources({
				{ name = "luasnip", priority = 900 },
				{ name = "pandoc_references", priority = 800 },
				{ name = "path", priority = 500 },
				{ name = "buffer", priority = 250, keyword_length = 3 },
			}),
		})
	end,
}
