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

        -- Rust
        rust = { "rustfmt" },

        -- Go
        go = { "gofumpt" },

        -- C/C++
        c = { "clang-format" },
        cpp = { "clang-format" },

        -- TOML
        toml = { "taplo" },

        -- YAML
        yaml = { "prettierd" },

        -- Svelte
        svelte = { "prettierd" },

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
