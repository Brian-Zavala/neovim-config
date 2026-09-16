-- Python venv-aware root detection for basedpyright.
-- MERGES with LazyVim's config. NOTE: `setup.basedpyright` only mutates opts
-- and returns nothing, so LazyVim proceeds with its single
-- `vim.lsp.config()` + `vim.lsp.enable()` path. Never call legacy
-- `lspconfig.X.setup()` here (that registers a second client).
-- (Interactive interpreter selection is handled by venv-selector.nvim.)
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Empty entry guarantees this spec's `setup` hook runs for the server
        -- (LazyVim only calls setup hooks for listed servers).
        basedpyright = {},
      },
      setup = {
        basedpyright = function(_, opts)
          -- Prefer a project root, fall back to cwd (supports monorepos and
          -- single-file scripts alike).
          opts.root_dir = function(bufnr, on_dir)
            local root = vim.fs.root(bufnr, {
              "pyproject.toml",
              "setup.py",
              "setup.cfg",
              "requirements.txt",
              "Pipfile",
              "pyrightconfig.json",
              ".git",
            })
            on_dir(root or vim.fn.getcwd())
          end
        end,
      },
    },
  },
}
