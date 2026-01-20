return {
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile", "InsertEnter" },
    opts = {
      enable_rename = true,
      enable_close = true,
      enable_close_on_slash = true,
    },
    config = function(_, opts)
      require("nvim-ts-autotag").setup(opts)
    end,
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
