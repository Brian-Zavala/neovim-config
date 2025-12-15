return {
  -- Completely disable ruff-lsp - only use pyright for Python
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruff_lsp = true, -- This disables ruff completely
      },
    },
  },
}

