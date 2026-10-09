require("purple.core")
require("purple.lazy")
require("purple.notes").setup()
local todo_float = require("purple.todofloat")
todo_float.setup({
	target_file = "~/notes/todo.md",
})
