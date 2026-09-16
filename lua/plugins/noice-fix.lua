return {
  "folke/noice.nvim",
  opts = {
    cmdline = {
      format = {
        -- Disable Tree-sitter highlighting for cmdline to prevent errors with Neovim 0.11+ bundled parser
        cmdline = { pattern = "^:", icon = "", lang = false },
        search_down = { kind = "search", pattern = "^/", icon = " ", lang = false },
        search_up = { kind = "search", pattern = "^%?", icon = " ", lang = false },
        filter = { pattern = "^:%s*!", icon = "$", lang = false },
        lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = false },
        calculator = { pattern = "^=", icon = "", lang = false },
      },
    },
  },
}
