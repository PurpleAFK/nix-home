-- Markdown note helpers: heading folds, task workflow, vault git sync
local M = {}

M.vault = vim.fn.expand("~/convergence")
local completed_heading = "## Completed tasks"

local function is_heading(line)
	return line:match("^#+%s") ~= nil
end

-- <CR>: fold/unfold on a heading, otherwise behave like normal <CR>
function M.enter()
	if is_heading(vim.api.nvim_get_current_line()) then
		return "za"
	end
	return "<CR>"
end

-- <CR> inside the obsidian vault: follow link > fold heading > toggle checkbox on list items
function M.obsidian_enter()
	local util = require("obsidian").util
	if util.cursor_on_markdown_link(nil, nil, true) then
		return "<cmd>ObsidianFollowLink<CR>"
	end
	local line = vim.api.nvim_get_current_line()
	if is_heading(line) then
		return "za"
	end
	if line:match("^%s*[-*+]%s") or line:match("^%s*%d+[.)]%s") then
		return "<cmd>ObsidianToggleCheckbox<CR>"
	end
	return "<CR>"
end

-- Fold every heading at `level` and deeper (0 = fold everything, 99 = open all)
function M.fold_level(level)
	return function()
		vim.wo.foldlevel = level
	end
end

-- Toggle the checkbox on the current line, turning plain lines into tasks
function M.toggle_task()
	local line = vim.api.nvim_get_current_line()
	local new
	if line:match("^%s*[-*+] %[ %]") then
		new = line:gsub("%[ %]", "[x]", 1)
	elseif line:match("^%s*[-*+] %[[xX]%]") then
		new = line:gsub("%[[xX]%]", "[ ]", 1)
	elseif line:match("^%s*[-*+] ") then
		new = line:gsub("^(%s*[-*+] )", "%1[ ] ", 1)
	else
		new = line:gsub("^(%s*)", "%1- [ ] ", 1)
	end
	vim.api.nvim_set_current_line(new)
end

-- Last line of the task at `row` (1-based), including its more-indented children
local function task_end(lines, row)
	local indent = #lines[row]:match("^%s*")
	local last = row
	for i = row + 1, #lines do
		local l = lines[i]
		if l:match("^%s*$") or #l:match("^%s*") <= indent then
			break
		end
		last = i
	end
	return last
end

-- Complete the task under the cursor and move it to the "Completed tasks" section
-- with a timestamp. On an already-completed task it un-completes it in place.
function M.complete_task()
	local buf = 0
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local line = lines[row]

	if line:match("^%s*[-*+] %[[xX]%]") then
		local undone = line:gsub("%[[xX]%]", "[ ]", 1):gsub(" `done: [^`]*`$", "")
		vim.api.nvim_set_current_line(undone)
		return
	end
	if not line:match("^%s*[-*+] %[ %]") then
		vim.notify("Not a task line", vim.log.levels.WARN)
		return
	end

	local last = task_end(lines, row)
	local block = vim.list_slice(lines, row, last)
	local indent = block[1]:match("^%s*")
	for i, l in ipairs(block) do
		block[i] = l:sub(#indent + 1)
	end
	block[1] = block[1]:gsub("%[ %]", "[x]", 1) .. " `done: " .. os.date("%Y-%m-%d %H:%M") .. "`"

	vim.api.nvim_buf_set_lines(buf, row - 1, last, false, {})

	lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local heading_row
	for i, l in ipairs(lines) do
		if l == completed_heading then
			heading_row = i
			break
		end
	end
	if heading_row then
		vim.api.nvim_buf_set_lines(buf, heading_row, heading_row, false, block)
	else
		local tail = { "", completed_heading }
		if lines[#lines] == "" then
			tail = { completed_heading }
		end
		vim.list_extend(tail, block)
		vim.api.nvim_buf_set_lines(buf, -1, -1, false, tail)
	end

	local count = vim.api.nvim_buf_line_count(buf)
	vim.api.nvim_win_set_cursor(0, { math.min(row, count), 0 })
end

-- Wrap the visual selection in ==...== (or unwrap if it already is)
function M.toggle_highlight()
	local s = vim.fn.getpos("v")
	local e = vim.fn.getpos(".")
	if s[2] > e[2] or (s[2] == e[2] and s[3] > e[3]) then
		s, e = e, s
	end
	local srow, scol, erow, ecol = s[2] - 1, s[3] - 1, e[2] - 1, e[3]
	local last = vim.api.nvim_buf_get_lines(0, erow, erow + 1, false)[1]
	ecol = math.min(ecol, #last)
	local text = vim.api.nvim_buf_get_text(0, srow, scol, erow, ecol, {})
	local joined = table.concat(text, "\n")
	local new
	if joined:match("^==.*==$") and #joined >= 4 then
		new = joined:sub(3, -3)
	else
		new = "==" .. joined .. "=="
	end
	vim.api.nvim_buf_set_text(0, srow, scol, erow, ecol, vim.split(new, "\n"))
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end

local function search_root()
	local file = vim.api.nvim_buf_get_name(0)
	if vim.startswith(file, M.vault) then
		return M.vault
	end
	return vim.uv.cwd()
end

-- Telescope list of open / completed tasks across the vault (or cwd)
function M.list_tasks(done)
	require("telescope.builtin").grep_string({
		prompt_title = done and "Completed tasks" or "Open tasks",
		search = done and "- [x]" or "- [ ]",
		cwd = search_root(),
		glob_pattern = "*.md",
	})
end

-- Commit and push the vault in the background
function M.sync(opts)
	opts = opts or {}
	local function run(cmd, next)
		vim.system(cmd, { cwd = M.vault, text = true }, function(res)
			vim.schedule(function()
				next(res)
			end)
		end)
	end
	run({ "git", "add", "-A" }, function()
		run({ "git", "diff", "--cached", "--quiet" }, function(diff)
			if diff.code == 0 then
				if not opts.quiet then
					vim.notify("Notes: nothing to sync")
				end
				return
			end
			run({ "git", "commit", "-m", "notes: " .. os.date("%Y-%m-%d %H:%M") }, function()
				run({ "git", "push" }, function(push)
					if push.code ~= 0 then
						vim.notify("Notes: push failed\n" .. (push.stderr or ""), vim.log.levels.ERROR)
					elseif not opts.quiet then
						vim.notify("Notes: synced")
					end
				end)
			end)
		end)
	end)
end

local timer
function M.toggle_autosync()
	if timer then
		timer:stop()
		timer:close()
		timer = nil
		vim.notify("Notes: auto-sync off")
		return
	end
	timer = vim.uv.new_timer()
	timer:start(0, 3 * 60 * 1000, vim.schedule_wrap(function()
		M.sync({ quiet = true })
	end))
	vim.notify("Notes: auto-sync on (every 3 min)")
end

function M.setup()
	vim.api.nvim_create_user_command("NotesSync", function()
		M.sync()
	end, { desc = "Commit and push the notes vault" })
	vim.api.nvim_create_user_command("NotesAutoSync", M.toggle_autosync, { desc = "Toggle 3-minute vault auto-sync" })
end

return M
