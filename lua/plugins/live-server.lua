return {
  {
    "barrett-ruth/live-server.nvim",
    build = "npm install -g live-server", -- installs live-server globally
    cmd = { "LiveServerStart", "LiveServerStop" }, -- lazy-load only when used
    config = function()
      require("live-server").setup({
        -- Optional configuration (defaults are fine)
        port = 5500, -- Port number (default)
        browser_command = "", -- Uses system default browser
        quiet = false, -- Show logs
        no_browser = false, -- Open browser automatically
        root = ".", -- Project root directory
        open = true, -- Auto-open index.html
      })
    end,
  },
}
