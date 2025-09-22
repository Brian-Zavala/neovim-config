return {
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile", "InsertEnter" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      opts = {
        -- Enable auto-close and auto-rename for tags
        enable_rename = true,
        enable_close = true,
        enable_close_on_slash = true,
      },
    },
    config = function(_, opts)
      require("nvim-ts-autotag").setup(opts)
    end,
  },
  -- Enhanced TreeSitter configuration for better HTML parsing
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
        "embedded_template",
      })

      -- Enhanced incremental selection for HTML
      opts.incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      }

      -- Better text objects for HTML tags
      opts.textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["at"] = "@tag.outer",
            ["it"] = "@tag.inner",
          },
        },
      }

      -- Ensure autotag is properly configured
      opts.autotag = {
        enable = true,
        enable_rename = true,
        enable_close = true,
        enable_close_on_slash = true,
        filetypes = {
          "html",
          "javascript",
          "typescript",
          "javascriptreact",
          "typescriptreact",
          "svelte",
          "vue",
          "tsx",
          "jsx",
          "rescript",
          "xml",
          "php",
          "markdown",
          "astro",
          "glimmer",
          "handlebars",
          "hbs",
          "eruby",
        },
      }

      return opts
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
  },
  -- Add nvim-treesitter-textobjects for better tag selection
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = "VeryLazy",
  },
  -- Alternative: Add a manual tag renaming as fallback
  {
    "AndrewRadev/tagalong.vim",
    event = { "BufReadPre", "BufNewFile" },
    ft = { "html", "xml", "jsx", "tsx", "vue", "svelte", "javascriptreact", "typescriptreact" },
    config = function()
      -- Configure tagalong as a fallback for complex nested structures
      vim.g.tagalong_filetypes = {
        "html",
        "xml",
        "jsx",
        "tsx",
        "javascriptreact",
        "typescriptreact",
        "vue",
        "svelte",
      }
      vim.g.tagalong_verbose = 0

      -- Add manual keybinding for force-renaming tags
      vim.keymap.set("n", "<leader>tr", function()
        vim.cmd("TagalongUpdate")
      end, { desc = "Force update matching tag" })
    end,
  },
}