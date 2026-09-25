require("config.remote_clipboard").setup()
-- Python LSP: basedpyright (the Mason-provided, tuned server).
-- LazyVim's default is pyright, which isn't installed here.
-- Must be set before plugins load (the lang.python extra reads it).
vim.g.lazyvim_python_lsp = "basedpyright"
-- File explorer: neo-tree (LazyVim defaults to the Snacks explorer).
-- Must be set before plugins load. Pairs with the explicit
-- `explorer = { enabled = false }` in disable-snacks-explorer.lua.
vim.g.lazyvim_explorer = "neo-tree"
-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- Enable relative line numbers (shows distance from current line)
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 3

-- No more .swp files
vim.opt.swapfile = false

-- Keep persistent undo instead (safer than swaps)

vim.opt.undofile = true
local undodir = vim.fn.stdpath("state") .. "/undo"
vim.opt.undodir = undodir
vim.fn.mkdir(undodir, "p") -- create the dir if missing
vim.opt.splitbelow = true

if vim.fn.has("win32") == 1 then
  -- PowerShell as the shell on Windows (see :h shell-powershell). Prefer
  -- PowerShell 7 (pwsh); a fresh Windows only has Windows PowerShell 5.1,
  -- which lacks $PSStyle, so that part of the flags is 7-only.
  local pwsh = vim.fn.executable("pwsh") == 1
  if pwsh or vim.fn.executable("powershell") == 1 then
    vim.opt.shell = pwsh and "pwsh" or "powershell"
    vim.opt.shellcmdflag = "-NoLogo -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';"
      .. (pwsh and "$PSStyle.OutputRendering='plaintext';" or "")
      .. "Remove-Alias -Force -ErrorAction SilentlyContinue tee;"
    vim.opt.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
    vim.opt.shellpipe = '2>&1 | %%{ "$_" } | tee %s; exit $LastExitCode'
    vim.opt.shellquote = ""
    vim.opt.shellxquote = ""
  end
elseif vim.fn.executable("zsh") == 1 then
  -- zsh when installed; otherwise keep the default ($SHELL)
  vim.opt.shell = vim.fn.exepath("zsh")
end

-- Force .jsx files to be recognized as 'javascriptreact' filetype
vim.filetype.add({
  extension = {
    jsx = "javascriptreact",
  },
})

-- Force the 'javascriptreact' filetype to use the 'tsx' parser
-- This is the critical step that fixes the highlighting
vim.treesitter.language.register("tsx", "javascriptreact")

-- Ensure ~/.cargo/bin is in PATH for rust-analyzer/cargo
local cargo_bin = vim.fn.expand("~/.cargo/bin")
if vim.fn.isdirectory(cargo_bin) == 1 then
  local sep = vim.fn.has("win32") == 1 and ";" or ":"
  vim.env.PATH = cargo_bin .. sep .. vim.env.PATH
end

-- Windows: when MSYS2's python comes first on PATH, put python.org Python
-- (per-user install) ahead of it inside Neovim. Mason builds its Python tools
-- (basedpyright, debugpy, ...) in venvs, and MSYS2's Linux-style venvs don't
-- work there. See config/toolchains.lua.
if vim.fn.has("win32") == 1 and vim.fn.exepath("python"):lower():find("msys", 1, true) then
  local installs = vim.fn.glob(vim.env.LOCALAPPDATA .. "/Programs/Python/Python3*", true, true)
  table.sort(installs, function(a, b)
    return (tonumber(a:match("Python3(%d+)$")) or 0) > (tonumber(b:match("Python3(%d+)$")) or 0)
  end)
  local py = installs[1]
  if py and vim.fn.executable(py .. "/python.exe") == 1 then
    vim.env.PATH = py .. ";" .. py .. "/Scripts;" .. vim.env.PATH
  end
end

-- AI completions: show as inline ghost text (Supermaven) instead of routing
-- them through the nvim-cmp popup. Accept full suggestion with <Tab>.
vim.g.ai_cmp = false
