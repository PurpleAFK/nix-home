return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8", -- Force a specific stable version instead of a branch
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"folke/todo-comments.nvim",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")

		telescope.setup({
			defaults = {
				path_display = { "smart" },
				-- ADD THIS: Fallback to prevent the previewer crash
				preview = {
					treesitter = false, -- This stops the "ft_to_lang" nil error instantly
				},
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous,
						["<C-j>"] = actions.move_selection_next,
					},
				},
			},
		})

		telescope.load_extension("fzf")

		-- keymaps
		local keymap = vim.keymap
		keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
		keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
		keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
		keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
		keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
		vim.keymap.set("n", "<leader>vf", function()
			require("telescope.builtin").find_files({ cwd = "~/convergence", hidden = false })
		end, { desc = "Vault: files" })

		vim.keymap.set("n", "<leader>vg", function()
			require("telescope.builtin").live_grep({ cwd = "~/convergence" })
		end, { desc = "Vault: grep" })

		vim.keymap.set("n", "<leader>vt", function()
			require("telescope.builtin").tags({ cwd = "~/convergence" })
		end, { desc = "Vault: tags" })
	end,
}
