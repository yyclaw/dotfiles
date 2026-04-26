local M = {}

local function read_glow_config()
	local home = os.getenv("HOME") or ""
	local candidates = {
		home .. "/Library/Preferences/glow/glow.yml",
		(os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")) .. "/glow/glow.yml",
	}
	local style, width
	for _, path in ipairs(candidates) do
		local f = io.open(path, "r")
		if f then
			for line in f:lines() do
				if not line:match("^%s*#") then
					style = style or line:match('^%s*style:%s*"?([^"#%s]+)"?')
					width = width or line:match('^%s*width:%s*(%d+)')
				end
			end
			f:close()
			if style or width then break end
		end
	end
	return style, tonumber(width)
end

local GLOW_STYLE, GLOW_WIDTH = read_glow_config()

local function cache_path(job)
	local cha = job.file.cha
	local mtime = cha and cha.mtime or 0
	local key = ya.hash(string.format(
		"glow:%s:%s:%s:%s",
		tostring(job.file.url),
		tostring(mtime),
		tostring(GLOW_STYLE or ""),
		tostring(GLOW_WIDTH or "")
	))
	local dir = os.getenv("TMPDIR") or "/tmp"
	return string.format("%syazi-glow-%s", dir:sub(-1) == "/" and dir or dir .. "/", key)
end

local function render_to_cache(job, path)
	local args = {}
	if GLOW_STYLE then table.insert(args, "--style"); table.insert(args, GLOW_STYLE) end
	if GLOW_WIDTH then table.insert(args, "--width"); table.insert(args, tostring(GLOW_WIDTH)) end
	table.insert(args, tostring(job.file.url))

	local child = Command("glow")
		:arg(args)
		:env("CLICOLOR_FORCE", "1")
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:spawn()

	if not child then return false end

	local output, err = child:wait_with_output()
	if not output or not output.status.success then return false end

	local f = io.open(path, "w")
	if not f then return false end
	f:write(output.stdout)
	f:close()
	return true
end

local function ensure_cache(job)
	local path = cache_path(job)
	local f = io.open(path, "r")
	if f then f:close(); return path end
	if render_to_cache(job, path) then return path end
	return nil
end

function M:preload(job)
	return ensure_cache(job) ~= nil
end

function M:peek(job)
	local path = ensure_cache(job)
	if not path then return require("code"):peek(job) end

	local f = io.open(path, "r")
	if not f then return require("code"):peek(job) end

	local i, lines = 0, ""
	for line in f:lines() do
		i = i + 1
		if i > job.skip then
			lines = lines .. line .. "\n"
			if i >= job.skip + job.area.h then break end
		end
	end
	f:close()

	if job.skip > 0 and i < job.skip + job.area.h then
		ya.emit("peek", { math.max(0, i - job.area.h), only_if = job.file.url, upper_bound = true })
	else
		lines = lines:gsub("\t", string.rep(" ", rt.preview.tab_size))
		ya.preview_widget(
			job,
			ui.Text.parse(lines):area(job.area):wrap(rt.preview.wrap == "yes" and ui.Wrap.YES or ui.Wrap.NO)
		)
	end
end

function M:seek(job) require("code"):seek(job) end

return M
