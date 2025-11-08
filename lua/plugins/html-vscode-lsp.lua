-- Use VSCode's HTML/CSS servers for all web development
-- This MERGES with LazyVim's config, doesn't replace it
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- HTML Language Server with FULL VSCode features
        html = {
          cmd = { "vscode-html-language-server", "--stdio" },
          filetypes = {
            "html", "htm", "shtml", "xhtml",
            "javascriptreact", "typescriptreact",
            "vue", "svelte", "astro", "php",
            "erb", "ejs", "njk", "liquid"
          },
          init_options = {
            configurationSection = { "html", "css", "javascript" },
            embeddedLanguages = {
              css = true,
              javascript = true,
            },
            provideFormatter = false,
          },
          settings = {
            html = {
              completion = {
                attributeDefaultValue = "doublequotes",
              },
              format = {
                enable = false, -- Use Prettier instead
              },
              suggest = {
                html5 = true,
              },
              validate = {
                scripts = true,
                styles = true,
              },
              hover = {
                documentation = true,
                references = true,
              },
              trace = {
                server = "off",
              },
            },
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