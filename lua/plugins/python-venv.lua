return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
              },
            },
          },
        },
      },
      setup = {
        pyright = function(_, opts)
          local lspconfig = require("lspconfig")
          local util = require("lspconfig.util")
          
          -- Override the default root_dir to always look for virtual environments
          opts.root_dir = function(fname)
            return util.root_pattern(
              "pyproject.toml",
              "setup.py",
              "setup.cfg",
              "requirements.txt",
              "Pipfile",
              "pyrightconfig.json",
              ".git"
            )(fname) or util.path.dirname(fname)
          end
          
          -- Auto-detect virtual environment
          opts.before_init = function(_, config)
            local root_dir = config.root_dir
            local venv_path = nil
            
            -- Check for common virtual environment locations
            local venv_names = { ".venv", "venv", "env", ".env" }
            for _, name in ipairs(venv_names) do
              local path = root_dir .. "/" .. name
              if vim.fn.isdirectory(path) == 1 then
                venv_path = path
                break
              end
            end
            
            if venv_path then
              config.settings.python = vim.tbl_deep_extend("force", config.settings.python or {}, {
                venvPath = root_dir,
                venv = vim.fn.fnamemodify(venv_path, ":t"),
                pythonPath = venv_path .. "/bin/python"
              })
            end
          end
          
          lspconfig.pyright.setup(opts)
          return true
        end,
      },
    },
  },
}