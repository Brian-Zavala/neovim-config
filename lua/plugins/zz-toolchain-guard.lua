-- Skip Mason packages whose toolchain isn't installed (see config/toolchains.lua),
-- so a fresh clone starts without "Could not find executable go/npm/python"
-- errors. The features come back by themselves once the toolchain is installed.
--
-- NOTE: the "zz-" prefix is load-bearing. lazy.nvim imports spec modules in
-- modname order and calls opts functions in that order, so this must run after
-- every other file that adds to ensure_installed / servers (conform.lua,
-- lsp.lua, html-vscode-lsp.lua, ...).
local tc = require("config.toolchains")

return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      tc.filter(opts.ensure_installed)
    end,
  },

  -- LazyVim hands every server without `mason = false` to mason-lspconfig.
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local ok, mappings = pcall(function()
        return require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package
      end)
      if not ok then
        return
      end
      for server, sopts in pairs(opts.servers or {}) do
        local pkg = mappings[server]
        if pkg and sopts ~= false and not tc.can_install(pkg) then
          tc.skipped[pkg] = tc.needs(pkg)
          if type(sopts) ~= "table" then
            sopts = {}
            opts.servers[server] = sopts
          end
          -- Don't install it, and don't start it (the binary isn't there).
          sopts.mason = false
          sopts.enabled = false
        end
      end
    end,
  },

  -- No C compiler: don't try to build treesitter parsers (LazyVim would show an
  -- "Unmet requirements" error on every start). Neovim's bundled parsers (lua,
  -- vim, vimdoc, markdown, c, query) keep working; the rest install on the
  -- first start after a compiler is installed.
  {
    "nvim-treesitter/nvim-treesitter",
    build = (not tc.cc.ok) and false or nil,
    opts = function(_, opts)
      if not tc.cc.ok then
        tc.skipped["treesitter parsers"] = "a C compiler"
        opts.ensure_installed = {}
      end
    end,
  },

  -- Only run linters whose command exists. On Windows nvim-lint runs every
  -- linter through cmd.exe, so a missing one (golangci-lint without Go,
  -- markdownlint-cli2 without npm, ...) pops "Linter command `cmd.exe`
  -- exited with code: 1" on every save. Uses LazyVim's `condition` extension.
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters = opts.linters or {}
      local names = {}
      for _, list in pairs(opts.linters_by_ft or {}) do
        for _, name in ipairs(type(list) == "table" and list or {}) do
          names[name] = true
        end
      end
      for name in pairs(names) do
        local ok, linter = pcall(require, "lint.linters." .. name)
        local override = opts.linters[name]
        -- Only table linters: LazyVim replaces a function linter with a table
        -- override instead of merging it.
        if ok and type(linter) == "table" and (override == nil or type(override) == "table") then
          override = override or {}
          local condition = override.condition
          override.condition = function(ctx)
            if condition and not condition(ctx) then
              return false
            end
            local l = require("lint").linters[name]
            local cmd = type(l) == "table" and l.cmd
            if type(cmd) == "function" then
              cmd = cmd()
            end
            return type(cmd) ~= "string" or vim.fn.executable(cmd) == 1
          end
          opts.linters[name] = override
        end
      end
    end,
  },

  -- The dap.core extra auto-installs a package for every registered adapter.
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = function(_, opts)
      local ok, source = pcall(require, "mason-nvim-dap.mappings.source")
      if not ok then
        return
      end
      local exclude = {}
      for adapter, pkg in pairs(source.nvim_dap_to_package) do
        if not tc.can_install(pkg) then
          exclude[#exclude + 1] = adapter
        end
      end
      if opts.automatic_installation and #exclude > 0 then
        opts.automatic_installation = { exclude = exclude }
      end
      tc.filter(opts.ensure_installed)
    end,
  },
}
