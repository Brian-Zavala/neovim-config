-- LSP servers, LazyVim-native style.
--
-- Every server is registered EXACTLY ONCE via `opts.servers`: LazyVim turns
-- each entry into a single `vim.lsp.config()` + `vim.lsp.enable()` pair with
-- correct mason install/exclude handling. Do NOT call
-- `lspconfig.<server>.setup()` or `vim.lsp.enable()` manually in this repo:
-- the old manual pattern produced duplicate clients (two rust-analyzers via
-- rustaceanvim, ts_ls fighting vtsls, clangd registered twice), which in turn
-- triggered the inlay-hint `Invalid 'col'` crash (see
-- after/plugin/inlay_hint_guard.lua).
--
-- Ownership map (who configures what — do not add a second owner):
--   typescript/javascript .. LazyVim `lang.typescript` + `vtsls` extras
--   python ............... LazyVim `lang.python` extra (basedpyright is
--                          selected via `vim.g.lazyvim_python_lsp` in
--                          lua/config/options.lua; venv root detection lives
--                          in lua/plugins/python-venv.lua)
--   rust ................. `mrcjkb/rustaceanvim` (settings extended below)
--   c/c++ ................ LazyVim `lang.clangd` extra
--   html/css ............. lua/plugins/html-vscode-lsp.lua
--   tailwind ............. LazyVim `lang.tailwind` extra
--   emmet ................ below (no LazyVim extra owns it)
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Global key LazyVim doesn't define: rename via inc-rename with a
        -- plain-LSP fallback. Buffer-local, only where rename is supported.
        -- (gd/gr/K/ca/cr/co/cM/ch/uh all come from LazyVim core/extras.)
        ["*"] = {
          keys = {
            {
              "<leader>rn",
              function()
                local ok, _ = pcall(require, "inc_rename")
                if ok then
                  return ":IncRename " .. vim.fn.expand("<cword>")
                end
                vim.lsp.buf.rename()
                return ""
              end,
              desc = "Rename Variable",
              expr = true,
              has = "rename",
            },
          },
        },
        -- Rust is served by rustaceanvim, NOT lspconfig. This entry only stops
        -- mason-lspconfig from auto-enabling a second rust-analyzer.
        rust_analyzer = { enabled = false },
        -- Python (basedpyright is selected in lua/config/options.lua).
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
                autoImportCompletions = true,
                inlayHints = {
                  variableTypes = true,
                  functionReturnTypes = true,
                  callArgumentNames = true,
                  pytestParameters = true,
                },
              },
            },
          },
        },
        -- Emmet (no LazyVim extra owns it).
        emmet_language_server = {
          filetypes = {
            "css",
            "eruby",
            "html",
            "javascript",
            "javascriptreact",
            "less",
            "sass",
            "scss",
            "svelte",
            "pug",
            "typescriptreact",
            "vue",
          },
        },
      },
    },
  },

  -- Rust-analyzer tuning for rustaceanvim (deep-merged with the LazyVim rust
  -- extra's own opts). Previously lived in a manual lspconfig.rust_analyzer
  -- setup, which spawned a SECOND rust-analyzer next to rustaceanvim's.
  {
    "mrcjkb/rustaceanvim",
    opts = {
      server = {
        default_settings = {
          ["rust-analyzer"] = {
            imports = {
              granularity = {
                group = "module",
              },
              prefix = "self",
            },
            -- Modern schema: `check` (the legacy `checkOnSave = { command }
            --` map is rejected by current rust-analyzer).
            check = {
              command = "clippy",
            },
            procMacro = {
              ignored = {
                ["async-trait"] = { "async_trait" },
                ["napi-derive"] = { "napi" },
                ["async-recursion"] = { "async_recursion" },
              },
            },
            inlayHints = {
              bindingModeHints = { enable = false },
              chainingHints = { enable = true },
              closingBraceHints = { enable = true, minLines = 25 },
              closureReturnTypeHints = { enable = "with_block" },
              lifetimeElisionHints = { enable = "never", useParameterNames = false },
              maxLength = 25,
              parameterHints = { enable = true },
              reborrowHints = { enable = "never" },
              renderColons = true,
              typeHints = {
                enable = true,
                hideClosureInitialization = false,
                hideNamedConstructor = false,
              },
            },
          },
        },
      },
    },
  },

  -- 2. Autocomplete (The UI)
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
      "hrsh7th/cmp-buffer", -- Text in current buffer
      "hrsh7th/cmp-path", -- File system paths
      "L3MON4D3/LuaSnip", -- Snippet engine (Important for React!)
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- Helper function to check if there are words before the cursor
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = {
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip", priority = 750 },
          { name = "buffer", priority = 500 },
          { name = "path", priority = 250 },
        }),
      })
    end,
  },

  -- 3. Auto-close tags
  {
    "windwp/nvim-ts-autotag",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
}
