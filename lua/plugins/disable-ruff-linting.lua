return {
  -- Completely disable ruff-lsp - only use pyright for Python
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruff_lsp = false,  -- This disables ruff completely
      },
    },
  },
}