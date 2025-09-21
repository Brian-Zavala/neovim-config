return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      use_libuv_file_watcher = true, -- auto-refresh when files change
      hijack_netrw_behavior = "open_current", -- prevent netrw from opening
    },
    window = {
      mappings = {
        ["<space>"] = "none", -- disable space mapping that might conflict
      },
    },
  },
}