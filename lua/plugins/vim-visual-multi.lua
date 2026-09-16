return {
  "mg979/vim-visual-multi",
  event = "BufReadPost",
  keys = {
    { "<leader>C", mode = { "n", "v" }, desc = "Start multi cursor and find next" },
    { "<C-j>", mode = { "n", "v" }, desc = "Add cursor down" },
    { "<C-k>", mode = { "n", "v" }, desc = "Add cursor up" },
    { "\\\\A", mode = { "n" }, desc = "Select all occurrences" },
    { "\\\\j", mode = { "n" }, desc = "Add cursor at position" },
  },
  init = function()
    vim.g.VM_maps = {
      ["Find Under"] = "<leader>C",
      ["Find Subword Under"] = "<leader>C",
      ["Add Cursor Down"] = "<C-j>",
      ["Add Cursor Up"] = "<C-k>",
      ["Select All"] = "\\\\A",
      ["Add Cursor At Pos"] = "\\\\j",
      ["Start Regex Search"] = "\\\\/",
      ["Visual Cursors"] = "\\\\c",
      ["Skip Region"] = "q",
      ["Remove Region"] = "Q",
      ["Increase"] = "+",
      ["Decrease"] = "-",
    }
    vim.g.VM_mouse_mappings = 0
    vim.g.VM_theme = "iceblue"
    vim.g.VM_show_warnings = 1
    vim.g.VM_silent_exit = 0
  end,
}