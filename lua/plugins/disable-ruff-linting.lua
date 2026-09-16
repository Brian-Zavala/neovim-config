return {
  -- Completely disable ruff-lsp - only use pyright for Python
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruff_lsp = { enabled = false }, -- keep ruff-lsp disabled (ruff server from the python extra covers lint)
      },
    },
  },
}

