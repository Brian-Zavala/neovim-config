-- Pure-Lua live server (v0.2+): no npm, no setup() call.
-- Installed from Forgejo; the GitHub repo is removed on 2026-10-31.
return {
  {
    url = "https://forge.barrettruth.com/barrettruth/live-server.nvim",
    name = "live-server.nvim",
    cmd = { "LiveServerStart", "LiveServerStop", "LiveServerToggle" }, -- lazy-load only when used
    init = function()
      vim.g.live_server = {
        port = 5500,
        browser = true, -- open the system default browser on start
      }
    end,
  },
}
