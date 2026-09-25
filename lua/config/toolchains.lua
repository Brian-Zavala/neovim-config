-- Which language toolchains exist on this machine, and which Mason packages
-- need them. Used by lua/plugins/zz-toolchain-guard.lua so a fresh clone
-- never asks Mason to build something it can't (no `go` -> skip gopls, ...),
-- and by `:checkhealth config`.
--
-- Install everything at once with scripts/install-deps.ps1 (Windows) or
-- scripts/install-deps.sh (Arch/Omarchy); see README.md.
local M = {}

local is_win = vim.fn.has("win32") == 1

---@param exe string
local function exe(exe)
  return vim.fn.executable(exe) == 1
end

-- MSYS2's Python creates Linux-style venvs (venv/bin) that Mason on Windows
-- can't use, so it doesn't count. python.org Python is picked up by options.lua.
local function usable_python()
  for _, name in ipairs(is_win and { "python", "python3" } or { "python3", "python" }) do
    local path = vim.fn.exepath(name)
    if path ~= "" then
      return not (is_win and path:lower():find("msys", 1, true))
    end
  end
  return false
end

---@type table<string, {ok: boolean, hint: string, purl: string}>
M.toolchains = {
  go = {
    purl = "pkg:golang/",
    ok = exe("go"),
    hint = is_win and "winget install GoLang.Go" or "sudo pacman -S go",
  },
  npm = {
    purl = "pkg:npm/",
    ok = exe("npm"),
    hint = is_win and "winget install OpenJS.NodeJS.LTS" or "sudo pacman -S nodejs npm",
  },
  python = {
    purl = "pkg:pypi/",
    ok = usable_python(),
    hint = is_win and "winget install Python.Python.3.13 (MSYS2 python doesn't work with Mason)"
      or "sudo pacman -S python python-pip",
  },
}

-- C compiler for building nvim-treesitter parsers. Same rules as LazyVim's
-- check (lazyvim/util/treesitter.lua), which also accepts gcc on Windows.
local function have_cc()
  if vim.env.CC or (not is_win and exe("cc")) then
    return true
  end
  if is_win then
    return exe("cl")
      or exe("gcc")
      or vim.fn.globpath(
          "C:/Program Files (x86)/Microsoft Visual Studio",
          "*/*/VC/Tools/MSVC/*/bin/Hostx64/x64/cl.exe",
          true,
          true
        )[1] ~= nil
  end
  return false
end
M.cc = {
  ok = have_cc(),
  hint = is_win and "winget install BrechtSanders.WinLibs.POSIX.UCRT" or "sudo pacman -S base-devel",
}

-- Fallback for when the Mason registry isn't downloaded yet (first launch on a
-- new PC). Keep in sync when enabling extras that pull in new packages.
local fallback = {
  go = { "gopls", "goimports", "gofumpt", "delve", "golangci-lint", "gomodifytags", "impl" },
  npm = {
    "vtsls", "typescript-language-server", "prettier", "biome", "oxlint", "oxfmt",
    "eslint-lsp", "json-lsp", "html-lsp", "css-lsp", "emmet-language-server",
    "yaml-language-server", "bash-language-server", "dockerfile-language-server",
    "docker-compose-language-service", "prisma-language-server",
    "tailwindcss-language-server", "markdownlint-cli2", "markdown-toc",
  },
  python = { "basedpyright", "pyright", "debugpy", "cmakelang", "cmakelint", "sqlfluff" },
}
local fallback_by_pkg = {}
for tc, pkgs in pairs(fallback) do
  for _, pkg in ipairs(pkgs) do
    fallback_by_pkg[pkg] = tc
  end
end

-- Packages that aren't built by a toolchain but are useless without one.
-- golangci-lint is a prebuilt binary but shells out to `go`; js-debug-adapter
-- is downloaded prebuilt but runs under node.
local runtime_needs = { ["golangci-lint"] = "go", ["js-debug-adapter"] = "npm" }

-- package name -> purl ("pkg:golang/...") from the downloaded Mason registry.
-- Built from the specs rather than get_package(), which logs an error to
-- mason.log for every name it doesn't know (e.g. before the first download).
local registry_ids
function M.registry_ids()
  if not registry_ids then
    local ok, specs = pcall(function()
      return require("mason-registry").get_all_package_specs()
    end)
    if not ok or type(specs) ~= "table" or #specs == 0 then
      return {} -- not downloaded yet: use the fallback table, retry next call
    end
    registry_ids = {}
    for _, spec in ipairs(specs) do
      registry_ids[spec.name] = spec.source and spec.source.id
    end
  end
  return registry_ids
end

---Name of the toolchain a Mason package needs, or nil if it's a prebuilt binary.
---@param pkg string Mason package name
---@return string?
function M.needs(pkg)
  if runtime_needs[pkg] then
    return runtime_needs[pkg]
  end
  local id = M.registry_ids()[pkg]
  if id then
    for tc, info in pairs(M.toolchains) do
      if vim.startswith(id, info.purl) then
        return tc
      end
    end
    return nil
  end
  return fallback_by_pkg[pkg]
end

---True when the package can be installed (and run) on this machine.
---@param pkg string
function M.can_install(pkg)
  local tc = M.needs(pkg)
  return tc == nil or M.toolchains[tc].ok
end

-- Packages the guard skipped this session, for :checkhealth config.
---@type table<string, string> package -> toolchain
M.skipped = {}

---Remove packages whose toolchain is missing from a list, in place.
---@param list string[]?
---@return string[]?
function M.filter(list)
  if not list then
    return list
  end
  for i = #list, 1, -1 do
    local pkg = list[i]
    if type(pkg) == "string" and not M.can_install(pkg) then
      M.skipped[pkg] = M.needs(pkg)
      table.remove(list, i)
    end
  end
  return list
end

return M
