return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter", -- Only load when you enter insert mode
    config = function()
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")

      -- 1. Setup nvim-autopairs
      require("nvim-autopairs").setup({
        -- By default, this is all you need for most languages
        -- You can customize things like:
        -- map_cr = true, -- Map <CR> (Enter) to balance pairs, etc.
      })

      -- 2. Integrate with nvim-cmp
      -- This tells the auto-pairs plugin to listen to the cmp completion events.
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },
}
