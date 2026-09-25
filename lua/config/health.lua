-- :checkhealth config
-- Reports the toolchains Mason needs and what the toolchain guard skipped.
local M = {}

function M.check()
  local tc = require("config.toolchains")
  local installer = vim.fn.has("win32") == 1 and "scripts/install-deps.ps1" or "scripts/install-deps.sh"

  vim.health.start("Toolchains (Mason packages that build from source)")
  for name, info in vim.spairs(tc.toolchains) do
    if info.ok then
      vim.health.ok(name .. " found")
    else
      vim.health.warn(name .. " missing: its Mason packages are skipped", { info.hint, "or run " .. installer })
    end
  end

  vim.health.start("Skipped Mason packages")
  if vim.tbl_isempty(tc.skipped) then
    vim.health.ok("none")
  else
    for pkg, needs in vim.spairs(tc.skipped) do
      vim.health.info(("%s (needs %s)"):format(pkg, needs))
    end
  end

  vim.health.start("Other tools")
  for _, tool in ipairs({ "git", "rg", "fd", "lazygit", "gh", "tree-sitter" }) do
    if vim.fn.executable(tool) == 1 then
      vim.health.ok(tool)
    else
      vim.health.warn(tool .. " not found", "run " .. installer)
    end
  end
  if tc.cc.ok then
    vim.health.ok("C compiler")
  else
    vim.health.warn("no C compiler: treesitter parsers are skipped", { tc.cc.hint, "or run " .. installer })
  end
end

return M
