-- Formatters (single owner: this file).
-- NOTE: one formatter per filetype. Chaining two formatters for the same
-- language makes them fight over style on every save, so don't add a second
-- entry anywhere (html-formatter.lua was merged in here and removed).
--
-- NOTE 2: the `lang.typescript.oxc` extra appends "oxfmt" to its own list of
-- filetypes (js/ts/json/vue/svelte/astro). For filetypes this file lists,
-- the explicit lists below win. svelte/astro are listed ONLY by that extra
-- and oxfmt rejects both, so they are cleared outright (otherwise every
-- save of those files errors).
return {
  -- Install the formatters conform invokes below.
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "prettier", "taplo" })
      return opts
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft or {}, {
        -- Web / JS / TS: prettier (print width 120, see formatters.prettier).
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        vue = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        markdown = { "prettier" },
        yaml = { "prettier" },

        -- JSON with Biome (fast).
        json = { "biome" },
        jsonc = { "biome" },

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

        -- Lua
        lua = { "stylua" },

        -- Shell
        sh = { "shfmt" },
        bash = { "shfmt" },
      })
      -- oxfmt supports neither; a leftover entry errors on every save.
      opts.formatters_by_ft.svelte = nil
      opts.formatters_by_ft.astro = nil
      opts.formatters = vim.tbl_deep_extend("force", opts.formatters or {}, {
        prettier = {
          prepend_args = {
            "--print-width",
            "120",
            "--tab-width",
            "2",
            "--use-tabs",
            "false",
            "--single-quote",
            "false",
            "--bracket-same-line",
            "false",
            "--html-whitespace-sensitivity",
            "css",
          },
        },
      })
      return opts
    end,
  },
}
