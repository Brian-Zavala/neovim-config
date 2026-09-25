-- The lang.markdown extra builds markdown-preview with mkdp#util#install(),
-- which runs `install.cmd` through 'shell'. With PowerShell as the shell that
-- fails ("install.cmd" isn't run from the current directory without ".\"),
-- so :MarkdownPreview never gets its binary. Run the installer directly.
return {
  {
    "iamcco/markdown-preview.nvim",
    optional = true,
    build = function(plugin)
      local app = plugin.dir .. "/app"
      local version = vim.json.decode(table.concat(vim.fn.readfile(plugin.dir .. "/package.json"), "")).version
      local cmd = vim.fn.has("win32") == 1
          and { "cmd.exe", "/c", (app .. "/install.cmd"):gsub("/", "\\"), "v" .. version }
        or { "sh", "./install.sh", "v" .. version }
      local res = vim.system(cmd, { cwd = app, text = true }):wait()
      if res.code ~= 0 then
        error("markdown-preview install failed:\n" .. (res.stderr or "") .. (res.stdout or ""))
      end
    end,
  },
}
