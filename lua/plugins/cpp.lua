-- CLion-like C++ workflow on top of LazyVim.
-- See docs/specs/2026-04-23-clion-like-cpp-neovim-design.md

return {
  -- CMake project integration: target picker, Build/Run/Debug commands.
  {
    "Civitasv/cmake-tools.nvim",
    ft = { "c", "cpp", "cmake" },
    cmd = {
      "CMakeGenerate",
      "CMakeBuild",
      "CMakeRun",
      "CMakeDebug",
      "CMakeClean",
      "CMakeSelectBuildTarget",
      "CMakeSelectLaunchTarget",
      "CMakeSelectBuildType",
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      cmake_command = "cmake",
      cmake_build_directory = "build",
      cmake_generate_options = { "-G", "Ninja" },
      cmake_soft_link_compile_commands = true,
      cmake_dap_configuration = {
        name = "cpp",
        type = "codelldb",
        request = "launch",
        stopOnEntry = false,
      },
    },
  },

  -- clangd AST / inlay-hint enhancements. Does NOT re-register clangd
  -- as an LSP server (existing lsp.lua setup is preserved).
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp" },
    opts = {
      ast = { role_icons = { type = "🄣", declaration = "🄓", expression = "🄔", statement = ";", specifier = "🄢", ["template argument"] = "🆃" } },
    },
  },

  -- Ensure the codelldb debug adapter is installed, and register it with nvim-dap.
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "williamboman/mason.nvim", opts = function(_, opts)
        opts.ensure_installed = opts.ensure_installed or {}
        table.insert(opts.ensure_installed, "codelldb")
      end },
    },
    opts = function()
      local dap = require("dap")
      if not dap.adapters["codelldb"] then
        dap.adapters["codelldb"] = {
          type = "server",
          host = "127.0.0.1",
          port = "${port}",
          executable = {
            command = vim.fn.exepath("codelldb"),
            args = { "--port", "${port}" },
          },
        }
      end
      for _, lang in ipairs({ "c", "cpp" }) do
        dap.configurations[lang] = dap.configurations[lang] or {}
        table.insert(dap.configurations[lang], {
          type = "codelldb",
          request = "launch",
          name = "Launch file (codelldb)",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/build/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        })
      end
    end,
  },
}
