-- Use nvim-emmet for proper Emmet expansion (li*3, div.container, etc)
return {
  {
    "olrtg/nvim-emmet",
    config = function()
      vim.keymap.set({ "n", "v" }, "<leader>xe", require("nvim-emmet").wrap_with_abbreviation)
    end,
    keys = {
      {
        "<C-y>,",
        mode = { "i", "n", "v" },
        function()
          require("nvim-emmet").expand_abbreviation()
        end,
        desc = "Expand Emmet abbreviation",
      },
      {
        "<Tab>",
        mode = "i",
        function()
          -- Try to expand Emmet first
          local expanded = require("nvim-emmet").expand_abbreviation()
          if not expanded then
            -- Fallback to regular tab
            return "<Tab>"
          end
        end,
        expr = true,
        desc = "Expand Emmet or Tab",
      },
    },
  },

  -- Keep emmet-language-server for LSP completions
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        emmet_language_server = {
          filetypes = {
            "html", "css", "scss", "javascript", "javascriptreact",
            "typescript", "typescriptreact", "vue", "svelte"
          },
        },
      },
    },
  },
}