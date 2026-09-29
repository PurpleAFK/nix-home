return {
	"epwalsh/obsidian.nvim",
	version = "*",
	ft = "markdown",
	event = {
		"BufReadPre " .. vim.fn.expand("~") .. "/convergence/**.md",
		"BufNewFile " .. vim.fn.expand("~") .. "/convergence/**.md",
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"hrsh7th/nvim-cmp",
		"nvim-telescope/telescope.nvim",
	},
	opts = {
		workspaces = { { name = "convergence", path = "~/convergence/" } },
		disable_frontmatter = true,
		notes_subdir = "concept",
		new_notes_location = "notes_subdir",
		daily_notes = {
			folder = "daily",
			date_format = "%Y-%m-%d",
			template = "daily.md",
		},
		templates = {
			folder = "_templates",
			date_format = "%Y-%m-%d",
			time_format = "%H:%M",
			substitutions = {
				-- Templater-style substitutions the obsidian.nvim runner understands
			},
		},
		completion = { nvim_cmp = true, min_chars = 2 },
		picker = { name = "telescope.nvim" },
		ui = { enable = false }, -- render-markdown.nvim owns the pretty layer
		attachments = { img_folder = "_attachments" },
		note_id_func = function(title)
			if title and title ~= "" then
				return title:gsub(" ", "-"):gsub("[^A-Za-z0-9%-_]", ""):lower()
			end
			return tostring(os.time())
		end,
		wiki_link_func = function(opts)
			-- Prefer [[filename|Display]] format
			if opts.label and opts.label ~= opts.path then
				return string.format("[[%s|%s]]", opts.path, opts.label)
			end
			return string.format("[[%s]]", opts.path)
		end,
		mappings = {
			["gf"] = {
				action = function()
					return require("obsidian").util.gf_passthrough()
				end,
				opts = { noremap = false, expr = true, buffer = true },
			},
			["<CR>"] = {
				action = function()
					return require("obsidian").util.smart_action()
				end,
				opts = { buffer = true, expr = true },
			},
		},
	},
	keys = {
		{ "<leader>od", "<cmd>ObsidianToday<cr>", desc = "Today's daily" },
		{ "<leader>oy", "<cmd>ObsidianYesterday<cr>", desc = "Yesterday" },
		{ "<leader>oT", "<cmd>ObsidianTomorrow<cr>", desc = "Tomorrow" },
		{ "<leader>on", "<cmd>ObsidianNew<cr>", desc = "New note" },
		{ "<leader>of", "<cmd>ObsidianQuickSwitch<cr>", desc = "Find note" },
		{ "<leader>og", "<cmd>ObsidianSearch<cr>", desc = "Grep vault" },
		{ "<leader>ol", ":ObsidianLink<cr>", mode = "v", desc = "Link selection" },
		{ "<leader>oL", ":ObsidianLinkNew<cr>", mode = "v", desc = "Link + create" },
		{ "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Backlinks" },
		{ "<leader>ot", "<cmd>ObsidianTags<cr>", desc = "Tags" },
		{ "<leader>oo", "<cmd>ObsidianOpen<cr>", desc = "Open in Obsidian app" },
		{ "<leader>op", "<cmd>ObsidianPasteImg<cr>", desc = "Paste image from clipboard" },
		{ "<leader>oe", "<cmd>ObsidianExtractNote<cr>", mode = "v", desc = "Extract to new note" },
		{ "<leader>or", "<cmd>ObsidianRename<cr>", desc = "Rename (updates links)" },
	},
}
