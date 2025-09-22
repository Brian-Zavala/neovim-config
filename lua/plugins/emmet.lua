return {
  -- Configure blink.cmp
  {
    "saghen/blink.cmp",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    opts = {
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          lsp = {
            score_offset = 100,
          },
        },
      },
      keymap = {
        preset = "super-tab",
      },
      completion = {
        accept = {
          auto_brackets = {
            enabled = true,
          },
        },
        documentation = {
          auto_show = true,
        },
      },
    },
  },
  -- Configure emmet-language-server
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local has_blink, blink = pcall(require, "blink.cmp")
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      if has_blink then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end

      opts.servers = opts.servers or {}

      opts.servers.emmet_language_server = {
        filetypes = {
          "html",
          "css",
          "scss",
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "vue",
          "svelte",
          "jsx",
          "tsx",
        },
        capabilities = capabilities,
      }

      opts.servers.html = {
        filetypes = { "html" },
        capabilities = capabilities,
      }

      return opts
    end,
  },
  -- Add a direct Emmet expansion keybinding that works for ALL abbreviations
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Create a universal Ctrl+E keybinding for Emmet expansion
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "html", "css", "javascriptreact", "typescriptreact", "vue", "svelte" },
        callback = function(ev)
          vim.keymap.set("i", "<C-e>", function()
            -- Get the current line and cursor position
            local line = vim.api.nvim_get_current_line()
            local row, col = unpack(vim.api.nvim_win_get_cursor(0))

            -- Find the start of the abbreviation (including numbers and operators)
            local start_col = col
            while start_col > 0 do
              local char = line:sub(start_col, start_col)
              if not char:match("[%w%+%*%>%.%#%$%-%@%!%[%]%(%)%{%}]") then
                break
              end
              start_col = start_col - 1
            end

            -- Extract the abbreviation
            local abbr = line:sub(start_col + 1, col)

            if abbr == "" then
              -- No abbreviation found, fallback to default behavior
              return vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-e>", true, false, true), "n", false)
            end

            -- Delete the abbreviation text
            vim.api.nvim_buf_set_text(0, row - 1, start_col, row - 1, col, {""})

            -- Manually expand common patterns that emmet-language-server might miss
            local expanded = nil

            -- Handle list patterns specifically
            local list_pattern = "^([uo]l)>li%*(%d+)$"
            local list_match = abbr:match(list_pattern)
            if list_match then
              local tag_type = abbr:match("^([uo]l)")
              local count = tonumber(abbr:match("%*(%d+)$"))
              local items = {}
              for i = 1, count do
                table.insert(items, "  <li></li>")
              end
              expanded = string.format("<%s>\n%s\n</%s>", tag_type, table.concat(items, "\n"), tag_type)
            end

            -- Handle simple li*N pattern
            local li_count = abbr:match("^li%*(%d+)$")
            if li_count then
              local count = tonumber(li_count)
              local items = {}
              for i = 1, count do
                table.insert(items, "<li></li>")
              end
              expanded = table.concat(items, "\n")
            end

            -- Handle ul*N or ol*N pattern
            local list_type, list_num = abbr:match("^([uo]l)%*(%d+)$")
            if list_type and list_num then
              local count = tonumber(list_num)
              local lists = {}
              for i = 1, count do
                table.insert(lists, string.format("<%s></%s>", list_type, list_type))
              end
              expanded = table.concat(lists, "\n")
            end

            -- Handle div*N and other tag*N patterns
            local tag, tag_count = abbr:match("^(%w+)%*(%d+)$")
            if tag and tag_count and not expanded then
              local count = tonumber(tag_count)
              local tags = {}
              for i = 1, count do
                table.insert(tags, string.format("<%s></%s>", tag, tag))
              end
              expanded = table.concat(tags, "\n")
            end

            if expanded then
              -- Insert the expanded text
              local lines = vim.split(expanded, "\n")
              vim.api.nvim_put(lines, "c", false, true)

              -- Move cursor to first tag content
              local first_close = expanded:find("><")
              if first_close then
                vim.api.nvim_win_set_cursor(0, {row, start_col + first_close})
              end
            else
              -- Fallback to LSP expansion for complex patterns
              -- Restore the abbreviation first
              vim.api.nvim_buf_set_text(0, row - 1, start_col, row - 1, start_col, {abbr})

              -- Try to trigger completion
              vim.defer_fn(function()
                require("blink.cmp").show()
                vim.defer_fn(function()
                  local cmp = require("blink.cmp")
                  if cmp.is_visible() then
                    cmp.accept()
                  end
                end, 100)
              end, 10)
            end
          end, {
            buffer = ev.buf,
            desc = "Expand Emmet abbreviation",
            silent = true
          })
        end,
      })
    end,
  },
  -- LuaSnip for lorem text
  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    config = function()
      local ls = require("luasnip")
      local s = ls.snippet
      local t = ls.text_node

      local lorem_snippets = {
        s("lor", {
          t("Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
        }),
        s("lorem", {
          t("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."),
        }),
      }

      local ft_list = { "html", "javascriptreact", "typescriptreact", "vue", "svelte" }
      for _, ft in ipairs(ft_list) do
        ls.add_snippets(ft, lorem_snippets)
      end
    end,
  },
  -- Ensure Mason installs emmet-language-server
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "emmet-language-server",
        "html-lsp",
      })
      return opts
    end,
  },
}