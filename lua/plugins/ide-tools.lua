return {
  -- ═══════════════════════════════════════════════════════════════════
  -- Incremental Rename (Visual "Type-Over" Renaming like VSCode)
  -- ═══════════════════════════════════════════════════════════════════
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    -- opts (not config): lazy.nvim auto-calls setup() with the merged opts,
    -- so future opts from the LazyVim extra keep working.
    opts = {
      input_buffer_type = "dressing", -- Use dressing.nvim for nice UI if available
    },
  },

  -- ═══════════════════════════════════════════════════════════════════
  -- Grug Far (Visual Search & Replace like VSCode)
  -- ═══════════════════════════════════════════════════════════════════
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    config = function()
      require("grug-far").setup({
        headerMaxWidth = 80,
        -- Engine: use ripgrep for speed
        engine = "ripgrep",
      })
    end,
    keys = {
      {
        "<leader>sr",
        function()
          require("grug-far").open({ transient = true })
        end,
        mode = { "n", "v" },
        desc = "Search & Replace (Grug Far)",
      },
      {
        "<leader>sR",
        function()
          require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
        end,
        mode = { "n" },
        desc = "Search & Replace (Current File)",
      },
      {
        "<leader>sw",
        function()
          require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
        end,
        mode = { "n" },
        desc = "Search Word Under Cursor",
      },
      {
        "<leader>sw",
        function()
          require("grug-far").with_visual_selection({ prefills = { paths = vim.fn.expand("%") } })
        end,
        mode = { "v" },
        desc = "Search Selection",
      },
    },
  },

  -- ═══════════════════════════════════════════════════════════════════
  -- Dressing.nvim (Better UI for inputs/selects)
  -- ═══════════════════════════════════════════════════════════════════
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {
      input = {
        enabled = true,
        default_prompt = "Input:",
        title_pos = "center",
        insert_only = true,
        start_in_insert = true,
        border = "rounded",
        relative = "cursor",
        prefer_width = 40,
        width = nil,
        max_width = { 140, 0.9 },
        min_width = { 20, 0.2 },
        win_options = {
          winblend = 0,
          wrap = false,
        },
      },
      select = {
        enabled = true,
        backend = { "telescope", "fzf_lua", "fzf", "builtin", "nui" },
        builtin = {
          border = "rounded",
          relative = "editor",
          win_options = {
            winblend = 0,
          },
        },
      },
    },
  },
}
