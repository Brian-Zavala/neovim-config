return {
  -- 1. LSP Configuration (Merged Mason + LSPConfig for dependency safety)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
    },
    config = function()
      -- Step 1: Setup Mason (Package Manager)
      require("mason").setup()

      -- Step 2: Setup Mason-LSPConfig (The bridge)
      require("mason-lspconfig").setup({
        -- "ts_ls" is the new name for tsserver (TypeScript/React server)
        ensure_installed = { 
          "ts_ls", 
          "html", 
          "cssls", 
          "tailwindcss", 
          "emmet_language_server",
          "pyright",  -- Python
          "clangd"    -- C/C++ (rust_analyzer removed - using rustup)
        },
      })

      -- Step 3: Setup LSP Servers
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Python Setup
      lspconfig.pyright.setup({ capabilities = capabilities })
      
      -- C/C++ Setup
      lspconfig.clangd.setup({ capabilities = capabilities })

      -- TypeScript / React Server Setup
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        init_options = {
          preferences = {
            disableSuggestions = true,
          },
        },
      })

      -- HTML/CSS Setup
      lspconfig.html.setup({ capabilities = capabilities })
      lspconfig.cssls.setup({ capabilities = capabilities })
      lspconfig.tailwindcss.setup({ capabilities = capabilities })

      -- Emmet Setup
      lspconfig.emmet_language_server.setup({
        filetypes = {
          "css", "eruby", "html", "javascript", "javascriptreact", 
          "less", "sass", "scss", "svelte", "pug", 
          "typescriptreact", "vue",
        },
        capabilities = capabilities,
      })

      -- Keymaps
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
      vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Go to References" })
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Info" })
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Variable" })
    end,
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
          { name = "nvim-lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
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
