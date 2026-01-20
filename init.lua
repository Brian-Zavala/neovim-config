-- ═══════════════════════════════════════════════════════════════════════════
-- CRITICAL FIX: Syntax Highlighting Race Condition (Neovim 0.11+)
-- ═══════════════════════════════════════════════════════════════════════════
-- PROBLEM: In Neovim 0.11+, treesitter's FileType autocmd registers AFTER the
--          first file's FileType event fires, causing no highlighting on first
--          buffer open. User must delete buffer and reopen to get highlighting.
--
-- ROOT CAUSE: LazyVim's treesitter config uses lazy-loading (event = "LazyFile")
--             which causes a race condition:
--             1. File opens → FileType event fires
--             2. Treesitter plugin loads (async via lazy.nvim)
--             3. Treesitter's highlighting autocmd is registered (too late!)
--             4. First buffer has no highlighting
--
-- SOLUTION: Enable Neovim's built-in syntax system BEFORE any plugins load.
--           This ensures the syntax foundation is ready when treesitter attaches.
--
-- MUST BE CALLED BEFORE require("config.lazy")!
-- ═══════════════════════════════════════════════════════════════════════════
vim.cmd("syntax enable")

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Load VSCode-specific config when running in VSCode
if vim.g.vscode then
  require("config.vscode")
end
