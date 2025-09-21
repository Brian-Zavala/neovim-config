-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Use 'jj' to escape from insert mode
map("i", "jj", "<Esc>", { desc = "Exit insert mode with jj" })

-- Use 'mm' to escape from visual mode  
map("v", "mm", "<Esc>", { desc = "Exit visual mode with mm" })

map("n", "<C-/>", function()
  _G.TermHereToggle()
end, { noremap = true, silent = true })
map("n", "<C-_>", function()
  _G.TermHereToggle()
end, { noremap = true, silent = true }) -- some layouts

-- custom return to main menu
vim.keymap.set("n", "<leader>h", function()
  require("snacks").dashboard()
end, { desc = "Home (LazyVim Menu)" })

-- Terminal mode mappings
-- Use 'jj' to exit terminal mode (go to normal mode)
map("t", "jj", "<C-\\><C-n>", { desc = "Exit terminal mode with jj" })

-- Unmap Escape in terminal mode so it passes through to the terminal application
-- This allows Escape to work in Claude Code and other terminal apps
-- We use pcall to avoid errors if the mapping doesn't exist
pcall(vim.keymap.del, "t", "<Esc>")

