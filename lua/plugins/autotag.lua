return {
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      opts = {
        -- Enable auto-close and auto-rename for tags
        enable_rename = true,
        enable_close = true,
        enable_close_on_slash = true,
      },
      -- Per filetype config
      per_filetype = {
        ["html"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
        ["javascript"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
        ["typescript"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
        ["javascriptreact"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
        ["typescriptreact"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
        ["jsx"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
        ["tsx"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
        ["vue"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
        ["svelte"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
        ["xml"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
        ["php"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
        ["markdown"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = false,
        },
        ["astro"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
        ["glimmer"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
        ["handlebars"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
        ["hbs"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
        ["eruby"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
      },
    },
    config = function(_, opts)
      require("nvim-ts-autotag").setup(opts)

      -- Extra setup for better performance
      vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
        vim.lsp.diagnostic.on_publish_diagnostics,
        {
          underline = true,
          virtual_text = {
            spacing = 5,
            severity = { min = vim.diagnostic.severity.WARN },
          },
          update_in_insert = true,
        }
      )
    end,
  },
  -- Ensure TreeSitter parsers are installed for the languages we need
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "html",
        "javascript",
        "typescript",
        "tsx",
        "vue",
        "svelte",
        "xml",
        "astro",
        "php",
      })

      -- Enable autotag module in treesitter
      opts.autotag = {
        enable = true,
        enable_rename = true,
        enable_close = true,
        enable_close_on_slash = true,
      }

      return opts
    end,
  },
}