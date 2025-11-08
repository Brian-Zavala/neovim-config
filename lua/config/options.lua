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
