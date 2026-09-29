return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	ft = { "markdown" },
	opts = {
		file_types = { "markdown" },
		latex = { enabled = false }, -- vimtex handles math preview
		heading = { icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " } },
		code = { style = "language", position = "right" },
		checkbox = {
			unchecked = { icon = "󰄱 " },
			checked = { icon = "󰱒 " },
		},
		link = {
			wiki = { icon = "󰌷 ", highlight = "@markup.link.markdown_inline" },
		},
	},
}
