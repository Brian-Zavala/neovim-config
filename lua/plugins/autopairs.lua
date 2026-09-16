return {
  -- Disable LazyVim's default mini.pairs to avoid conflicts
  -- Note: LazyVim renamed the plugin from echasnovski/mini.pairs to nvim-mini/mini.pairs
  {
    "nvim-mini/mini.pairs",
    enabled = false,
  },

  -- Robust auto-pairs with VSCode/JetBrains-like behavior
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = { "hrsh7th/nvim-cmp" },
    config = function()
      local npairs = require("nvim-autopairs")
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")

      npairs.setup({
        check_ts = true, -- Use treesitter to check for pairs (smarter behavior)
        ts_config = {
          lua = { "string", "source" }, -- Don't add pairs in lua string treesitter nodes
          javascript = { "string", "template_string" },
          typescript = { "string", "template_string" },
          java = false, -- Don't check treesitter on java
        },
        disable_filetype = { "TelescopePrompt", "spectre_panel", "snacks_picker_input" },
        disable_in_macro = true,
        disable_in_visualblock = false,
        disable_in_replace_mode = true,
        enable_moveright = true,
        enable_afterquote = true, -- Add bracket pairs after quote
        enable_check_bracket_line = true, -- Check bracket in same line
        enable_bracket_in_quote = true,
        enable_abbr = false,
        break_undo = true,
        map_cr = true, -- Map <CR> to confirm pairs
        map_bs = true, -- Map <BS> to delete pairs
        map_c_h = false,
        map_c_w = false,

        -- Fast wrap: press <M-e> (Alt+e) to wrap the next word/expression
        -- Example: |"hello" -> press <M-e> then ( -> ("hello")
        fast_wrap = {
          map = "<M-e>",
          chars = { "{", "[", "(", '"', "'" },
          pattern = [=[[%'%"%>%]%)%}%,]]=],
          end_key = "$",
          before_key = "h",
          after_key = "l",
          cursor_pos_before = true,
          keys = "qwertyuiopzxcvbnmasdfghjkl",
          manual_position = true,
          check_comma = true,
          highlight = "Search",
          highlight_grey = "Comment",
        },
      })

      -- Integrate with nvim-cmp for "myFunc(|)" behavior
      -- When you select a function from completion, it auto-adds () and places cursor inside
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },
}
