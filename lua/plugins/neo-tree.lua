return {
  "nvim-neo-tree/neo-tree.nvim",
  -- Neo-tree is the file explorer: selected via `vim.g.lazyvim_explorer`
  -- in options.lua, so the `editor.neo-tree` extra owns all explorer keys.
  -- Snacks explorer stays disabled (disable-snacks-explorer.lua).
  --
  -- LSP import updates on rename/move are handled by that extra too
  -- (Snacks.rename.on_rename_file on FILE_MOVED / FILE_RENAMED), so no
  -- custom event_handlers here.
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
