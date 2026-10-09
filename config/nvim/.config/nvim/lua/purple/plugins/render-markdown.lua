-- Markdown layout ported from linkarzu's neobean config
-- https://github.com/linkarzu/dotfiles-latest/tree/main/neovim/neobean
-- Style: heading text in a per-level colour on a soft tint of that colour,
-- inline-code chips and ==highlights==. Works with any colorscheme: kanagawa
-- uses a hand-picked palette, other themes derive colours from their syntax groups.

local TINT = 0.3 -- heading block strength: 0 = invisible, 1 = solid colour

-- Hand-picked palettes per colorscheme (matched against the start of vim.g.colors_name)
local palettes = {
	kanagawa = {
		headings = {
			"#957FB8", -- oniViolet
			"#7E9CD8", -- crystalBlue
			"#7FB4CA", -- springBlue
			"#E6C384", -- carpYellow
			"#FFA066", -- surimiOrange
			"#D27E99", -- sakuraPink
		},
		code = "#E6C384", -- carpYellow
		code_bg = "#2A2A37", -- sumiInk4
		mark = "#E6C384", -- carpYellow
		mark_bg = "#49443C", -- winterYellow
	},
}

local function hex(n)
	return n and string.format("#%06x", n)
end

local function get(groups, attr)
	for _, name in ipairs(groups) do
		local h = vim.api.nvim_get_hl(0, { name = name, link = false })
		if h[attr] then
			return hex(h[attr])
		end
	end
end

-- mix two "#RRGGBB" colours; t = weight of `a`
local function blend(a, b, t)
	local out = "#"
	for i = 2, 6, 2 do
		local x, y = tonumber(a:sub(i, i + 1), 16), tonumber(b:sub(i, i + 1), 16)
		out = out .. string.format("%02x", math.floor(x * t + y * (1 - t) + 0.5))
	end
	return out
end

-- Pick heading/code colours from the active theme's syntax groups
local function derive(bg)
	local fg = get({ "Normal" }, "fg") or (vim.o.background == "light" and "#303030" or "#d0d0d0")
	local headings = {}
	local seen = {}
	local candidates = {
		{ "Keyword", "Statement" },
		{ "Function" },
		{ "Special", "@punctuation.special" },
		{ "Identifier", "@variable" },
		{ "Constant", "Number" },
		{ "Type" },
		{ "String" },
		{ "PreProc" },
		{ "Title" },
	}
	-- prefer distinct colours so levels are distinguishable
	for _, groups in ipairs(candidates) do
		local col = get(groups, "fg")
		if col and not seen[col] and #headings < 6 then
			seen[col] = true
			table.insert(headings, col)
		end
	end
	while #headings < 6 do
		table.insert(headings, headings[#headings] or fg)
	end
	local warm = get({ "Constant", "Number" }, "fg") or headings[4]
	return {
		headings = headings,
		code = warm,
		code_bg = blend(fg, bg, 0.08),
		mark = warm,
		mark_bg = blend(warm, bg, 0.2),
	}
end

local function set_highlights()
	local hl = function(name, spec)
		vim.api.nvim_set_hl(0, name, spec)
	end
	local bg = get({ "Normal" }, "bg") or (vim.o.background == "light" and "#ffffff" or "#1a1a1a")
	local name = vim.g.colors_name or ""
	local p
	for prefix, pal in pairs(palettes) do
		if name:sub(1, #prefix) == prefix then
			p = pal
		end
	end
	p = p or derive(bg)

	for i, col in ipairs(p.headings) do
		-- soft tinted block: heading colour text on a muted version of it
		local tint = blend(col, bg, TINT)
		hl("@markup.heading." .. i .. ".markdown", { fg = col, bg = tint, bold = true })
		hl("Headline" .. i .. "Bg", { fg = col, bg = tint })
		hl("Headline" .. i .. "Fg", { fg = col, bg = tint, bold = true })
	end
	hl("RenderMarkdownCodeInline", { fg = p.code, bg = p.code_bg })
	hl("@markup.raw.markdown_inline", { fg = p.code, bg = p.code_bg })
	hl("RenderMarkdownInlineHighlight", { fg = p.mark, bg = p.mark_bg })
	hl("Folded", { bg = "NONE" })
end

return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	ft = { "markdown" },
	opts = {
		file_types = { "markdown" },
		latex = { enabled = false }, -- vimtex handles math preview
		bullet = { enabled = true },
		checkbox = {
			enabled = true,
			unchecked = { icon = "   󰄱 ", highlight = "RenderMarkdownUnchecked", scope_highlight = nil },
			checked = { icon = "   󰱒 ", highlight = "RenderMarkdownChecked", scope_highlight = nil },
		},
		html = {
			enabled = true,
			comment = { conceal = false },
		},
		link = {
			image = "󰥶 ",
			custom = {
				youtu = { pattern = "youtu%.be", icon = "󰗃 " },
			},
			wiki = { icon = "󰌷 ", highlight = "@markup.link.markdown_inline" },
		},
		heading = {
			sign = false,
			icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
			backgrounds = { "Headline1Bg", "Headline2Bg", "Headline3Bg", "Headline4Bg", "Headline5Bg", "Headline6Bg" },
			foregrounds = { "Headline1Fg", "Headline2Fg", "Headline3Fg", "Headline4Fg", "Headline5Fg", "Headline6Fg" },
			-- block hugs the text instead of a full-width bar
			width = "block",
			left_pad = 1,
			right_pad = 2,
		},
		-- ==highlighted text== (Obsidian style)
		inline_highlight = { enabled = true },
		code = {
			style = "none",
		},
	},
	config = function(_, opts)
		set_highlights()
		-- re-apply after any :colorscheme so kanagawa doesn't override them
		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("purple_markdown_hl", { clear = true }),
			callback = set_highlights,
		})
		require("render-markdown").setup(opts)
	end,
}
