return {
  -- Install prettier for HTML formatting
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "prettier"
      })
      return opts
    end,
  },
  -- Configure conform.nvim to use prettier for HTML files
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        javascript = { "prettier", "biome" },
        javascriptreact = { "prettier", "biome" },
        typescript = { "prettier", "biome" },
        typescriptreact = { "prettier", "biome" },
        vue = { "prettier" },
        svelte = { "prettier" },
        markdown = { "prettier" },
      },
      formatters = {
        prettier = {
          prepend_args = {
            "--print-width", "120",
            "--tab-width", "2",
            "--use-tabs", "false",
            "--single-quote", "false",
            "--bracket-same-line", "false",
            "--html-whitespace-sensitivity", "css",
          },
        },
      },
    },
  },
}