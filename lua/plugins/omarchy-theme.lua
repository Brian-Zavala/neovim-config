-- Follow the Omarchy theme when there is one, without committing Omarchy's
-- theme.lua symlink (a broken link / plain-text file on other machines).
--
-- lua/plugins/theme.lua is machine-local and gitignored: Omarchy symlinks it
-- to the current theme, and omarchy-win writes a stand-in on Windows. When it
-- exists lazy.nvim loads it as its own spec and this file does nothing.
-- Otherwise, on an Omarchy machine, recreate Omarchy's symlink (other code,
-- like the theme hotreload, reads it) and load the theme from here this time.
-- Anywhere else: LazyVim's default colorscheme (tokyonight).
--
-- NOTE: sorts before theme-pin.lua, whose opts function must run last.
local link = vim.fn.stdpath("config") .. "/lua/plugins/theme.lua"
if vim.uv.fs_stat(link) then
  return {}
end

local file = require("config.colorscheme_pin").theme_file()
if not file then
  return {}
end

if vim.fn.has("win32") == 0 then
  -- Omarchy links the state path (newer) or the ~/.config path (older).
  pcall(vim.uv.fs_symlink, file, link)
end

local ok, spec = pcall(dofile, file)
return ok and type(spec) == "table" and spec or {}
