-- Fix CSS LSP to work with Tailwind directives
-- This MERGES with LazyVim's config, doesn't replace it
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- CSS Language Server - just add Tailwind compatibility
        cssls = {
          settings = {
            css = {
              lint = {
                unknownAtRules = "ignore", -- Ignore @tailwind, @apply, @layer
              },
            },
            scss = {
              lint = {
                unknownAtRules = "ignore",
              },
            },
          },
        },
      },
    },
  },
}