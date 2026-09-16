-- Neovim-only colorscheme pin on top of Omarchy theming.
--
-- lua/plugins/theme.lua is a symlink to Omarchy's per-theme neovim.lua, so on
-- its own every start follows the Omarchy theme. A pin file overrides that:
-- present = use this colorscheme, absent = follow Omarchy. Last action wins:
-- picking a colorscheme in Neovim pins it, `omarchy theme set` unpins it.
local M = {}

M.file = vim.fn.stdpath("state") .. "/omarchy-colorscheme-pin"
M.applying = false -- true while a colorscheme is applied programmatically (hotreload)

-- Colorscheme Omarchy wants, read fresh from the symlinked spec. dofile rather
-- than require so package.loaded caching cannot return a stale value after a
-- theme switch.
function M.omarchy()
	local ok, spec = pcall(dofile, vim.fn.stdpath("config") .. "/lua/plugins/theme.lua")
	if not ok or type(spec) ~= "table" then
		return nil
	end
	for _, s in ipairs(spec) do
		if s[1] == "LazyVim/LazyVim" and s.opts and s.opts.colorscheme then
			return s.opts.colorscheme
		end
	end
end

-- Slug of the current Omarchy theme, used to detect a theme switch in-session.
function M.omarchy_theme_name()
	local f = io.open(vim.fn.expand("~/.local/state/omarchy/current/theme.name"), "r")
	if not f then
		return nil
	end
	local name = vim.trim(f:read("*a") or "")
	f:close()
	return name
end

function M.read()
	local f = io.open(M.file, "r")
	if not f then
		return nil
	end
	local name = vim.trim(f:read("*a") or "")
	f:close()
	return name ~= "" and name or nil
end

function M.clear()
	os.remove(M.file)
end

function M.write(name)
	-- Picking Omarchy's own colorscheme means "follow Omarchy", so clear instead of pin.
	if name == nil or name == "" or name == M.omarchy() then
		return M.clear()
	end
	vim.fn.mkdir(vim.fn.fnamemodify(M.file, ":h"), "p")
	local f = assert(io.open(M.file, "w"))
	f:write(name, "\n")
	f:close()
end

function M.effective()
	return M.read() or M.omarchy()
end

return M
