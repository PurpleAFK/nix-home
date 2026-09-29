local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {}, {
	-- Fraction: type 'ff'
	s({ trig = "ff", snippetType = "autosnippet" }, {
		t("\\frac{"),
		i(1),
		t("}{"),
		i(2),
		t("}"),
	}),

	-- Inline Math: type 'mk'
	s({ trig = "mk", snippetType = "autosnippet" }, {
		t("$"),
		i(1),
		t("$"),
	}),
}
