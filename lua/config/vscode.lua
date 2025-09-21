-- VSCode-specific Neovim configuration
if vim.g.vscode then
  -- Line numbers
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.numberwidth = 3
  
  -- Search settings
  vim.opt.hlsearch = true
  vim.opt.incsearch = true
  vim.opt.ignorecase = true
  vim.opt.smartcase = true
  
  -- Better defaults
  vim.opt.clipboard = "unnamedplus"
  vim.opt.scrolloff = 5
  vim.opt.sidescrolloff = 5
  
  -- VSCode-specific keybindings
  local keymap = vim.keymap.set
  local opts = { noremap = true, silent = true }
  
  -- Multi-cursor functionality (Ctrl+D)
  keymap('n', '<C-d>', "<Cmd>call VSCodeNotify('editor.action.addSelectionToNextFindMatch')<CR>", opts)
  keymap('x', '<C-d>', "<Cmd>call VSCodeNotify('editor.action.addSelectionToNextFindMatch')<CR>", opts)
  keymap('n', 'gb', "<Cmd>call VSCodeNotify('editor.action.addSelectionToNextFindMatch')<CR>", opts)
  keymap('n', 'gB', "<Cmd>call VSCodeNotify('editor.action.selectHighlights')<CR>", opts)
  
  -- Clear search highlights with backslash
  keymap('n', '\\', ':nohl<CR>', opts)
  
  -- Better navigation
  keymap('n', 'H', '^', opts)
  keymap('n', 'L', '$', opts)
  keymap('x', 'H', '^', opts)
  keymap('x', 'L', '$', opts)
  
  -- Window navigation
  keymap('n', '<C-h>', "<Cmd>call VSCodeNotify('workbench.action.focusLeftGroup')<CR>", opts)
  keymap('n', '<C-j>', "<Cmd>call VSCodeNotify('workbench.action.focusBelowGroup')<CR>", opts)
  keymap('n', '<C-k>', "<Cmd>call VSCodeNotify('workbench.action.focusAboveGroup')<CR>", opts)
  keymap('n', '<C-l>', "<Cmd>call VSCodeNotify('workbench.action.focusRightGroup')<CR>", opts)
  
  -- File operations
  keymap('n', '<leader>w', "<Cmd>call VSCodeNotify('workbench.action.files.save')<CR>", opts)
  keymap('n', '<leader>q', "<Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>", opts)
  keymap('n', '<leader>f', "<Cmd>call VSCodeNotify('workbench.action.quickOpen')<CR>", opts)
  
  -- Code actions
  keymap('n', '<leader>ca', "<Cmd>call VSCodeNotify('editor.action.quickFix')<CR>", opts)
  keymap('n', '<leader>rn', "<Cmd>call VSCodeNotify('editor.action.rename')<CR>", opts)
  keymap('n', 'gd', "<Cmd>call VSCodeNotify('editor.action.revealDefinition')<CR>", opts)
  keymap('n', 'gr', "<Cmd>call VSCodeNotify('editor.action.goToReferences')<CR>", opts)
  keymap('n', 'gi', "<Cmd>call VSCodeNotify('editor.action.goToImplementation')<CR>", opts)
  
  -- Comment toggle
  keymap('n', '<leader>/', "<Cmd>call VSCodeNotify('editor.action.commentLine')<CR>", opts)
  keymap('x', '<leader>/', "<Cmd>call VSCodeNotify('editor.action.commentLine')<CR>", opts)
  
  -- Format document
  keymap('n', '<leader>p', "<Cmd>call VSCodeNotify('editor.action.formatDocument')<CR>", opts)
  
  -- Better paste in visual mode
  keymap('x', 'p', '"_dP', opts)
  
  -- Disable some default LazyVim plugins that conflict with VSCode
  vim.g.vscode_disable_plugins = {
    "neo-tree.nvim",
    "bufferline.nvim",
    "lualine.nvim",
    "noice.nvim",
    "notify",
    "dressing.nvim",
    "alpha-nvim",
    "dashboard-nvim"
  }
end