local header = [[
                                                                   
      ████ ██████           █████      ██                 btw
     ███████████             █████                            
     █████████ ███████████████████ ███   ███████████  
    █████████  ███    █████████████ █████ ██████████████  
   █████████ ██████████ █████████ █████ █████ ████ █████  
 ███████████ ███    ███ █████████ █████ █████ ████ █████ 
██████  █████████████████████ ████ █████ █████ ████ ██████
]]
local keys = {
  { icon = " ", key = "f", desc = "find file", action = ":lua Snacks.dashboard.pick('files')" },
  { icon = " ", key = "n", desc = "new file", action = ":ene | startinsert" },
  { icon = " ", key = "g", desc = "grep text", action = ":lua Snacks.dashboard.pick('live_grep')" },
  { icon = " ", key = "r", desc = "recent file", action = ":lua Snacks.dashboard.pick('oldfiles')" },
  {
    icon = " ",
    key = "c",
    desc = "config",
    action = ":lua Snacks.dashboard.pick('files', { cwd = vim.fn.stdpath('config') })",
  },
  { icon = " ", key = "p", desc = "projects", action = ":lua Snacks.picker.projects()" },
  { icon = " ", key = "T", desc = "terminal", action = ":ToggleTerm direction=float" },
  { icon = " ", key = "s", desc = "restore session", section = "session" },
  {
    icon = " ",
    key = "G",
    desc = "lazygit",
    action = ":lua Snacks.lazygit()",
    enabled = vim.fn.executable("lazygit") == 1,
  },
  { icon = " ", key = "t", desc = "colorscheme", action = ":lua Snacks.picker.colorschemes()" },
  { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
  { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras", enabled = package.loaded.lazy ~= nil },
  { icon = "󰏖 ", key = "m", desc = "Mason", action = ":Mason", enabled = package.loaded.lazy ~= nil },
  { icon = " ", key = "q", desc = "quit", action = ":qa" },
}

-- Section paddings (blank lines after each section)
local header_pad = 3
local keys_pad = 3
local keys_gap = 1
local recent_limit = 5

-- Deterministically estimate the block height so a spacer can push the
-- startup ("Neovim loaded …") line down to the last row of the window.
local function used_lines()
  local n = 0
  for _ in header:gmatch("\n") do
    n = n + 1
  end
  local hlines = n + 1 -- header rows

  local nkeys = 0
  for _, k in ipairs(keys) do
    if k.enabled == nil or k.enabled == true then
      nkeys = nkeys + 1
    end
  end
  local klines = nkeys + math.max(nkeys - 1, 0) * keys_gap -- keys + gaps

  local recent = 1 + recent_limit + 1 -- title + files + padding
  local startup = 1

  return hlines + header_pad + klines + keys_pad + recent + startup
end

return {
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      enabled = true,
      width = 70,
      preset = {
        header = header,
        keys = keys,
      },
      formats = {
        key = function(item)
          return { { "[", hl = "special" }, { item.key, hl = "key" }, { "]", hl = "special" } }
        end,
      },
      sections = {
        { section = "header", padding = header_pad },
        { section = "keys", gap = keys_gap, padding = keys_pad },
        {
          icon = " ",
          title = "Recent Files",
          section = "recent_files",
          limit = recent_limit,
          indent = 2,
          padding = 1,
        },
        -- spacer: fills the gap so startup lands on the bottom row.
        -- Must be a *section function* (snacks calls it); a function on the
        -- `text` field is never invoked and crashes the dashboard render.
        function()
          local h = vim.api.nvim_win_get_height(0) + (vim.o.laststatus >= 2 and 1 or 0)
          local blanks = math.max(h - used_lines(), 0)
          return { text = "", padding = blanks }
        end,
        { section = "startup" },
      },
    },
  },
}
