-- Use VSCode's HTML/CSS servers for all web development
-- This MERGES with LazyVim's config, doesn't replace it
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- HTML Language Server (includes built-in Emmet support)
        html = {
          filetypes = {
            "html", "htm", "shtml", "xhtml",
            "javascriptreact", "typescriptreact",
            "vue", "svelte", "astro", "php",
            "erb", "ejs", "njk", "liquid"
          },
        },
        -- CSS Language Server with Tailwind compatibility
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
            less = {
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