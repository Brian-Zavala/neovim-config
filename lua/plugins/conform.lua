return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        -- JavaScript/TypeScript with Biome (fast!)
        javascript = { "biome" },
        typescript = { "biome" },
        javascriptreact = { "biome" },
        typescriptreact = { "biome" },
        json = { "biome" },

        -- Or use Prettier if you prefer
        -- javascript = { "prettierd" },
        -- typescript = { "prettierd" },

        -- Python with Ruff
        python = { "ruff_format", "ruff_organize_imports" },

        -- Lua
        lua = { "stylua" },

        -- Shell
        sh = { "shfmt" },
        bash = { "shfmt" },

        -- HTML/CSS
        html = { "prettierd" },
        css = { "prettierd" },

        -- Markdown
        markdown = { "prettierd" },
      },
    },
  },
}
