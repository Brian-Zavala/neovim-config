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

-- Wrapper: Comment even blank lines with gcc, with auto-indentation
map("n", "gcc", function()
  local line = vim.api.nvim_get_current_line()

  if line:match("^%s*$") then
    -- Get the filetype's commentstring
    local cs = vim.bo.commentstring
    if cs and cs ~= "" then
      -- Strip the "%s" placeholder, keep only leader
      local leader = cs:gsub("%%s", ""):gsub("^%s+", ""):gsub("%s+$", "")

      -- If line is completely empty, use vim's auto-indent
      if line == "" then
        -- Insert comment leader and let vim handle indentation
        vim.api.nvim_feedkeys("i" .. leader .. "\027", "n", false) -- \027 is ESC
      else
        -- Line has whitespace, preserve it
        local indent = line:match("^(%s*)") or ""
        vim.api.nvim_set_current_line(indent .. leader)
      end

      -- Trigger auto-indent to fix indentation
      vim.cmd("normal! ==") -- Auto-indent current line
    end
  else
    -- Fallback to mini.comment's gcc (feed keys to it)
    vim.api.nvim_feedkeys("gcc", "n", false)
  end
end, { desc = "Comment line (works on empty lines too, with auto-indent)" })

map("n", "<leader>ls", "<cmd>LiveServerStart<CR>", { desc = "Start Live Server" })
map("n", "<leader>le", "<cmd>LiveServerStop<CR>", { desc = "Stop Live Server" })
