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

-- Set shell to zsh (matches system shell)
vim.opt.shell = "/usr/bin/zsh"

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
  vim.env.PATH = cargo_bin .. ":" .. vim.env.PATH
end

-- AI completions: show as inline ghost text (Supermaven) instead of routing
-- them through the nvim-cmp popup. Accept full suggestion with <Tab>.
vim.g.ai_cmp = false
