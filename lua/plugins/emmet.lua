return {
  -- Enable blink.cmp extra if not already enabled
  {
    "saghen/blink.cmp",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    opts = {
      -- Configure sources to include LSP (which includes emmet-ls)
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        -- Prioritize LSP completions for better emmet support
        providers = {
          lsp = {
            score_offset = 100, -- Higher priority for LSP completions
          },
        },
      },
      -- Use super-tab preset for Tab expansion
      keymap = {
        preset = "super-tab",
        -- Custom keymaps for emmet-like expansion
        ["<Tab>"] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.accept()
            else
              return cmp.select_and_accept()
            end
          end,
          "snippet_forward",
          "fallback",
        },
        ["<C-e>"] = { "select_and_accept" }, -- Ctrl+E to expand
      },
      -- Enable experimental features for better emmet support
      completion = {
        accept = {
          -- Auto-insert brackets and parentheses
          auto_brackets = {
            enabled = true,
          },
        },
        -- Show docs automatically
        documentation = {
          auto_show = true,
        },
      },
    },
  },
  -- Configure emmet-ls and HTML LSP servers with better nested support
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Get blink.cmp capabilities
      local has_blink, blink = pcall(require, "blink.cmp")
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      if has_blink then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end

      opts.servers = opts.servers or {}

      -- Enhanced emmet configuration
      opts.servers.emmet_language_server = {
        filetypes = {
          "html",
          "typescriptreact",
          "javascriptreact",
          "javascript",
          "typescript",
          "css",
          "sass",
          "scss",
          "less",
          "jsx",
          "tsx",
          "vue",
          "svelte",
          "xml",
          "php",
          "eruby",
          "htmldjango",
        },
        init_options = {
          showSuggestionsAsSnippets = true,
          showExpandedAbbreviation = "always",
          showAbbreviationSuggestions = true,
          includeLanguages = {
            javascript = "javascriptreact",
            typescript = "typescriptreact",
            vue = "html",
            ["javascript.jsx"] = "javascriptreact",
            ["typescript.tsx"] = "typescriptreact",
          },
          variables = {},
          preferences = {
            ["emmet.triggerExpansionOnTab"] = true,
            ["emmet.includeLanguages"] = {
              javascript = "javascriptreact",
              typescript = "typescriptreact",
            },
          },
        },
        capabilities = capabilities,
      }

      -- Also configure html-lsp for better HTML support
      opts.servers.html = {
        filetypes = { "html", "htmldjango", "eruby" },
        init_options = {
          configurationSection = { "html", "css", "javascript" },
          embeddedLanguages = {
            css = true,
            javascript = true,
          },
          provideFormatter = false, -- Use prettier instead
        },
        capabilities = capabilities,
      }

      return opts
    end,
  },
  -- Add custom keymaps for better emmet expansion in nested contexts
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Add custom keybinding for expanding Emmet abbreviation at any position
      vim.keymap.set("i", "<M-e>", function()
        -- This will work better for nested contexts
        vim.cmd("stopinsert")
        vim.lsp.buf.execute_command({
          command = "_emmet.expandAbbreviation",
        })
        vim.cmd("startinsert!")
      end, { desc = "Expand Emmet abbreviation (nested)" })

      -- Alternative method using direct emmet expansion
      vim.keymap.set("i", "<C-y>e", function()
        local line = vim.api.nvim_get_current_line()
        local col = vim.api.nvim_win_get_cursor(0)[2]
        local word_start = col

        -- Find the start of the abbreviation
        while word_start > 0 and line:sub(word_start, word_start):match("[%w%+%*%>%.%#%$%-%@%!%[%]%(%)]+") do
          word_start = word_start - 1
        end

        local abbr = line:sub(word_start + 1, col)
        if abbr and #abbr > 0 then
          -- Try to expand via LSP
          vim.lsp.buf.execute_command({
            command = "emmet.expand",
            arguments = { vim.api.nvim_buf_get_name(0), vim.fn.line(".") - 1, col },
          })
        end
      end, { desc = "Expand Emmet in place" })
    end,
  },
  -- Add custom snippets for lorem text using LuaSnip (works with blink.cmp)
  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    config = function()
      local ls = require("luasnip")
      local s = ls.snippet
      local t = ls.text_node

      -- Define lorem snippets for multiple file types
      local lorem_snippets = {
        s("lor", {
          t("Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
        }),
        s("lorem", {
          t("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."),
        }),
        s("lorem5", {
          t({
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
            "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.",
            "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum.",
            "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia.",
          }),
        }),
      }

      -- Add snippets to relevant file types
      local ft_list = { "html", "javascriptreact", "typescriptreact", "vue", "svelte", "php", "eruby", "htmldjango" }
      for _, ft in ipairs(ft_list) do
        ls.add_snippets(ft, lorem_snippets)
      end
    end,
  },
  -- Ensure Mason installs emmet-language-server and HTML LSP
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "emmet-language-server",
        "html-lsp",
      },
    },
  },
}