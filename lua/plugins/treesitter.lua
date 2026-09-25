return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- Explicitly prevent lazy loading (belt-and-suspenders with syntax enable)
    lazy = false,

    opts = function(_, opts)
      -- Add Omarchy 3.0+ custom languages to LazyVim's defaults
      vim.list_extend(opts.ensure_installed, {
        "rust",
        "cpp",
        "css",
      })
      return opts
    end,
    -- Missing parsers / build requirements are reported by LazyVim itself
    -- and by :checkhealth nvim-treesitter.
  },
}
