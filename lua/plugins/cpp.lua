-- CLion-like C++ workflow on top of LazyVim.
-- See docs/specs/2026-04-23-clion-like-cpp-neovim-design.md

-- Shared so both the plugin spec's `opts` and the keymap-level setup-refresh
-- reference the exact same table. Hoisted here (not inlined in opts) because
-- cmake-tools.nvim captures cwd at module-load time, so if the active project
-- changes mid-session we call setup() again to rebuild config with new cwd.
local cmake_opts = {
  cmake_command = "cmake",
  cmake_build_directory = "build",
  cmake_generate_options = { "-G", "Ninja" },
  -- Symlinks need admin/Developer Mode on Windows, so copy there instead
  cmake_soft_link_compile_commands = vim.fn.has("win32") == 0,
  -- cmake-tools builds this autocmd pattern from a backslash cwd on Windows,
  -- which makes setup() throw "Failed to set autocmd"
  cmake_regenerate_on_save = vim.fn.has("win32") == 0,
  cmake_dap_configuration = {
    name = "cpp",
    type = "codelldb",
    request = "launch",
    stopOnEntry = false,
  },
}

return {
  -- CMake project integration: target picker, Build/Run/Debug commands.
  {
    "Civitasv/cmake-tools.nvim",
    -- Deliberately NOT ft-loaded: FileType fires during BufRead, before our
    -- BufReadPost autocmd can tcd to the project root, which means the plugin
    -- would cache the wrong cwd. Load only on first :CMake* command instead,
    -- which happens via our keymaps *after* ensure_cmake_root() runs.
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
    init = function()
      local set = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
      end

      -- Resolve the nearest CMakeLists.txt-rooted project and tab-cd into it.
      -- Search order:
      --   1. Current buffer's file path (walk up)
      --   2. Every listed loaded buffer's file path (walk up)
      --      — catches the "focus is on neo-tree sidebar" case
      --   3. Current working directory (walk up)
      -- Returns true if a project root was found and cwd now points at it.
      local function ensure_cmake_root()
        local candidates = {}
        local function push(p)
          if p and p ~= "" and vim.fn.filereadable(p) == 1 then
            table.insert(candidates, p)
          end
        end
        push(vim.api.nvim_buf_get_name(0))
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.bo[buf].buflisted and vim.api.nvim_buf_is_loaded(buf) then
            push(vim.api.nvim_buf_get_name(buf))
          end
        end
        table.insert(candidates, vim.fn.getcwd())

        for _, path in ipairs(candidates) do
          local root = vim.fs.root(path, { "CMakeLists.txt" })
          if root then
            if vim.fn.getcwd() ~= root then
              vim.cmd("tcd " .. vim.fn.fnameescape(root))
              vim.notify("CMake project: " .. root, vim.log.levels.INFO)
            end
            return true
          end
        end
        return false
      end

      -- Track which cwd cmake-tools.nvim was last configured against.
      -- When cwd changes (project switch), call setup again to rebuild its
      -- internal Config with the new cwd — this is the ONLY way to update
      -- the plugin's module-level cached cwd.
      local last_cmake_cwd = nil

      -- cmake-tools asks for a launch/build target even when the project has only
      -- one; pick it automatically so Shift+F10 is a single keypress. Wrapped on
      -- first use (after Snacks has installed its vim.ui.select).
      local single_target_wrapped = false
      local function auto_pick_single_target()
        if single_target_wrapped then
          return
        end
        single_target_wrapped = true
        local select = vim.ui.select
        vim.ui.select = function(items, opts, on_choice)
          local prompt = opts and opts.prompt or ""
          if #items == 1 and prompt:match("^Select .*target") then
            return on_choice(items[1], 1)
          end
          return select(items, opts, on_choice)
        end
      end

      local cmake = function(cmd)
        return function()
          if not ensure_cmake_root() then
            vim.notify(
              "No CMakeLists.txt found above any open file or the cwd.\n"
                .. "Open a file from a CMake project first (any .cpp/.h inside the project).",
              vim.log.levels.WARN,
              { title = "CMake" }
            )
            return
          end
          local cur = vim.fn.getcwd()
          if package.loaded["cmake-tools"] and last_cmake_cwd ~= cur then
            require("cmake-tools").setup(cmake_opts)
          end
          last_cmake_cwd = cur
          auto_pick_single_target()
          vim.cmd(cmd)
        end
      end

      -- CMake build/run/debug. Self-healing: each key re-resolves project root first.
      set("n", "<C-F9>",   cmake("CMakeBuild"),              "CMake: Build")
      set("n", "<S-F10>",  cmake("CMakeRun"),                "CMake: Run")
      set("n", "<S-F9>",   cmake("CMakeDebug"),              "CMake: Debug")
      set("n", "<C-S-F9>", function()
        ensure_cmake_root()
        vim.cmd("CMakeClean")
        vim.cmd("CMakeBuild")
      end, "CMake: Rebuild")
      -- F6 for target picker: <leader>cm is :Mason, <leader>cM is TypeScript
      -- "Add Missing Imports". Function key avoids both.
      set("n", "<F6>",     cmake("CMakeSelectBuildTarget"),  "CMake: Select target")

      -- Also set cwd when opening a C/C++ file, so typing :CMakeBuild directly
      -- (without going through our keymaps) also works.
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
        pattern = { "*.c", "*.cc", "*.cpp", "*.cxx", "*.h", "*.hh", "*.hpp", "*.hxx", "CMakeLists.txt" },
        callback = function(ev)
          local file = vim.api.nvim_buf_get_name(ev.buf)
          if file == "" then return end
          local root = vim.fs.root(file, { "CMakeLists.txt" })
          if root and vim.fn.getcwd() ~= root then
            vim.cmd("tcd " .. vim.fn.fnameescape(root))
          end
        end,
      })

      -- Debugger step commands — require('dap') lazy-loads nvim-dap
      set("n", "<F9>",   function() require("dap").toggle_breakpoint() end, "DAP: Toggle breakpoint")
      set("n", "<F8>",   function() require("dap").step_over() end,         "DAP: Step over")
      set("n", "<F7>",   function() require("dap").step_into() end,         "DAP: Step into")
      set("n", "<S-F8>", function() require("dap").step_out() end,          "DAP: Step out")

      -- Complete Statement: close unclosed (), [], {}, append `;` if missing,
      -- drop to a new auto-indented line below. For if/while/for/switch/else
      -- block keywords, append ` {` and open an indented block with closing `}`.
      local function complete_statement()
        local row = vim.api.nvim_win_get_cursor(0)[1]
        local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""

        local stack = {}
        local in_str, str_char = false, nil
        local i = 1
        while i <= #line do
          local c = line:sub(i, i)
          if in_str then
            if c == "\\" then
              i = i + 1
            elseif c == str_char then
              in_str = false
            end
          else
            if c == '"' or c == "'" then
              in_str, str_char = true, c
            elseif c == "/" and line:sub(i, i + 1) == "//" then
              break
            elseif c == "(" or c == "[" or c == "{" then
              table.insert(stack, c)
            elseif c == ")" or c == "]" or c == "}" then
              if #stack > 0 then table.remove(stack) end
            end
          end
          i = i + 1
        end

        -- If the only unclosed opener is a trailing `{`, leave it alone.
        local line_trimmed = line:match("^(.-)%s*$") or ""
        if #stack == 1 and stack[1] == "{" and line_trimmed:sub(-1) == "{" then
          stack = {}
        end

        local close_map = { ["("] = ")", ["["] = "]", ["{"] = "}" }
        local closers = ""
        for j = #stack, 1, -1 do
          closers = closers .. close_map[stack[j]]
        end

        local updated = line .. closers
        local trimmed = updated:match("^(.-)%s*$") or updated
        local stripped = trimmed:gsub("^%s+", "")
        local last = trimmed:sub(-1)

        local is_block = stripped:match("^if%s*%(")
          or stripped:match("^while%s*%(")
          or stripped:match("^for%s*%(")
          or stripped:match("^switch%s*%(")
          or stripped:match("^else%s+if%s*%(")
          or stripped:match("^else$")
          or stripped:match("^do$")

        if is_block and last ~= "{" then
          updated = trimmed .. " {"
        elseif last == "{" or last == ";" then
          updated = trimmed
        else
          updated = trimmed .. ";"
        end

        vim.api.nvim_buf_set_lines(0, row - 1, row, false, { updated })
        vim.api.nvim_win_set_cursor(0, { row, #updated })

        if updated:sub(-1) == "{" then
          local outer_indent = (line:match("^(%s*)") or "")
          vim.cmd("normal! o")
          local inner_row = vim.api.nvim_win_get_cursor(0)[1]
          vim.api.nvim_buf_set_lines(0, inner_row, inner_row, false,
            { outer_indent .. "}" })
          local inner_line = vim.api.nvim_buf_get_lines(0, inner_row - 1, inner_row, false)[1] or ""
          vim.api.nvim_win_set_cursor(0, { inner_row, #inner_line })
          vim.cmd("startinsert!")
        else
          vim.cmd("normal! o")
          vim.cmd("startinsert!")
        end
      end

      set({ "n", "i" }, "<C-S-CR>", function()
        if vim.fn.mode():sub(1, 1) == "i" then
          vim.cmd("stopinsert")
        end
        complete_statement()
      end, "Complete current statement")
    end,
    opts = cmake_opts,
  },

  -- clangd AST / inlay-hint enhancements. Does NOT re-register clangd
  -- as an LSP server (the server is owned by LazyVim's lang.clangd extra).
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp" },
    opts = {
      ast = { role_icons = { type = "🄣", declaration = "🄓", expression = "🄔", statement = ";", specifier = "🄢", ["template argument"] = "🆃" } },
    },
  },

  -- clangd flags:
  --  * --log=error: Neovim logs every line a server writes to stderr at ERROR
  --    level, and clangd's default (info) writes one per request, so lsp.log
  --    grows by megabytes. Only real errors are kept.
  --  * --query-driver (Windows): let clangd ask the g++ on PATH (e.g. MSYS2 /
  --    WinLibs) for its system headers (<iostream> etc.), otherwise it guesses
  --    an MSVC target and can't find libstdc++. Skipped when no g++ exists.
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local clangd = opts.servers and opts.servers.clangd
      if not clangd then
        return
      end
      local cmd = vim.deepcopy(clangd.cmd or { "clangd" })
      table.insert(cmd, "--log=error")
      local gxx = vim.fn.has("win32") == 1 and vim.fn.exepath("g++") or ""
      if gxx ~= "" then
        local dir = vim.fs.dirname(vim.fs.normalize(gxx))
        table.insert(cmd, "--query-driver=" .. dir .. "/*.exe")
      end
      clangd.cmd = cmd
    end,
  },

  -- Register the codelldb adapter with nvim-dap (Mason installs codelldb via
  -- the lang.clangd / lang.rust extras). The command is resolved on PATH when
  -- a session starts, so it works on the first run before Mason finishes.
  {
    "mfussenegger/nvim-dap",
    opts = function()
      local dap = require("dap")
      if not dap.adapters["codelldb"] then
        dap.adapters["codelldb"] = {
          type = "server",
          host = "127.0.0.1",
          port = "${port}",
          executable = {
            command = "codelldb",
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
