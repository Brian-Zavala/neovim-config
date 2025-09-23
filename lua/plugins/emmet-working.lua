-- Proper Emmet setup with Blink.cmp for LazyVim
return {
  -- Configure emmet-language-server properly
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

  -- Add Tab key expansion for Emmet with Blink.cmp
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      -- Add custom keymap for Tab
      opts.keymap = vim.tbl_deep_extend("force", opts.keymap or {}, {
        preset = "default",
        ["<Tab>"] = {
          function(cmp)
            -- If completion menu is visible, accept it
            if cmp.is_visible() then
              return cmp.accept()
            else
              -- Trigger completion
              return cmp.show()
            end
          end,
          "snippet_forward",
          "fallback"
        },
        ["<C-Space>"] = { "show" },
      })

      -- Make completions auto-trigger on emmet patterns
      opts.completion = vim.tbl_deep_extend("force", opts.completion or {}, {
        trigger = {
          show_on_keyword = true,
          show_on_trigger_character = true,
        },
      })

      return opts
    end,
  },

  -- Alternative: Add manual emmet expansion function
  {
    "folke/which-key.nvim",
    optional = true,
    opts = function(_, opts)
      -- Create autocmd for HTML-like files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "html", "css", "javascriptreact", "typescriptreact", "vue", "svelte" },
        callback = function(ev)
          -- Map Ctrl+E to force emmet expansion
          vim.keymap.set("i", "<C-y>,", function()
            -- Save current position
            local row, col = unpack(vim.api.nvim_win_get_cursor(0))
            local line = vim.api.nvim_get_current_line()

            -- Find abbreviation start
            local abbr_start = col
            while abbr_start > 0 and line:sub(abbr_start, abbr_start):match("[%w*+>.-]") do
              abbr_start = abbr_start - 1
            end

            -- Set cursor to start of abbreviation
            vim.api.nvim_win_set_cursor(0, {row, abbr_start})

            -- Trigger LSP completion
            vim.lsp.buf.completion()

            -- Wait a bit then accept first completion
            vim.defer_fn(function()
              local cmp = require("blink.cmp")
              if cmp.is_visible() then
                cmp.accept({ index = 1 })
              end
            end, 100)
          end, { buffer = ev.buf, desc = "Expand Emmet abbreviation" })
        end,
      })

      return opts
    end,
  },
}