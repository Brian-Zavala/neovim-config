# CLion-like C++ Neovim — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Configure the existing LazyVim setup at `~/.config/nvim/` to provide CLion-parity C++ development — build/run/debug of CMake projects plus `Ctrl+Shift+Enter` "Complete Statement".

**Architecture:** Enable the `dap.core` LazyVim extra to pull in `nvim-dap`/`dap-ui`/`mason-nvim-dap`, then add one new plugin file `lua/plugins/cpp.lua` that declares `cmake-tools.nvim`, `clangd_extensions.nvim`, a `codelldb` adapter, Mason ensure-installed for `codelldb`, all CLion keymaps, and the Complete Statement function. The existing custom clangd config in `lsp.lua:115-132` is preserved untouched.

**Tech Stack:** LazyVim, `nvim-dap`, `nvim-dap-ui`, `mason-nvim-dap`, `codelldb`, `cmake-tools.nvim`, `clangd_extensions.nvim`, clangd 22 (already installed).

**Reference spec:** `~/.config/nvim/docs/specs/2026-04-23-clion-like-cpp-neovim-design.md`

**Working directory for all git operations:** `~/.config/nvim/` (this is a git repo; commits land on the current branch).

---

## Task 1: Enable LazyVim `dap.core` extra

**Files:**
- Modify: `~/.config/nvim/lazyvim.json`

- [ ] **Step 1: Read current `lazyvim.json`**

Run: `cat ~/.config/nvim/lazyvim.json`
Confirm: the `extras` array currently contains `"lazyvim.plugins.extras.lang.cmake"` but does NOT contain any `dap.*` entry.

- [ ] **Step 2: Add `dap.core` entry**

Insert `"lazyvim.plugins.extras.dap.core",` into the `extras` array. `dap` sorts alphabetically between `coding` and `editor`, so the correct placement is directly after the last `coding.*` entry and before the first `editor.*` entry:

```diff
     "lazyvim.plugins.extras.coding.yanky",
+    "lazyvim.plugins.extras.dap.core",
     "lazyvim.plugins.extras.editor.dial",
```

- [ ] **Step 3: Verify JSON is still valid**

Run: `python3 -c "import json; json.load(open('/home/baz/.config/nvim/lazyvim.json'))" && echo "OK: valid JSON"`
Expected: `OK: valid JSON`

- [ ] **Step 4: Open Neovim and let Lazy sync**

Run: `nvim +"Lazy sync" +qa`
Expected: Lazy installs `nvim-dap`, `nvim-dap-ui`, `mason-nvim-dap`, and related packages. No errors printed.

- [ ] **Step 5: Verify DAP plugins are loaded**

Run: `nvim +"lua print(pcall(require, 'dap'))" +"lua print(pcall(require, 'dapui'))" +qa 2>&1 | grep -E "true|false"`
Expected: two `true` lines.

- [ ] **Step 6: Commit**

```bash
cd ~/.config/nvim && git add lazyvim.json && git commit -m "feat(dap): enable LazyVim dap.core extra for C++ debugging"
```

---

## Task 2: Create `cpp.lua` with `cmake-tools.nvim` plugin spec

**Files:**
- Create: `~/.config/nvim/lua/plugins/cpp.lua`

- [ ] **Step 1: Create the initial plugin file with `cmake-tools.nvim` + Mason ensure codelldb**

Write this as the entire initial content of `~/.config/nvim/lua/plugins/cpp.lua`:

```lua
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
```

- [ ] **Step 2: Confirm the file parses as valid Lua**

Run: `nvim --headless -c "luafile /home/baz/.config/nvim/lua/plugins/cpp.lua" -c "qa" 2>&1`
Expected: no output (empty stdout/stderr = success). If you see a syntax error, fix it before continuing.

- [ ] **Step 3: Install plugins and codelldb via Lazy + Mason**

Run: `nvim +"Lazy sync" +"MasonInstall codelldb" +qa`
Expected: cmake-tools.nvim, clangd_extensions.nvim install cleanly; Mason downloads codelldb (may take 30–90s). No errors.

- [ ] **Step 4: Verify codelldb binary is on PATH from Neovim**

Run: `nvim --headless -c "lua print(vim.fn.exepath('codelldb'))" -c "qa" 2>&1`
Expected: a non-empty path ending in `.../mason/bin/codelldb` (or similar). If empty, Mason's shim directory is not on PATH — check `:Mason` in Neovim.

- [ ] **Step 5: Verify `:CMakeGenerate` command exists**

Run: `nvim --headless -c "lua print(vim.fn.exists(':CMakeGenerate'))" -c "qa" 2>&1`
Expected: output `2` (Vim's return for "command exists"). Full integration test — actually building and running the CS-330 project — is deferred to Task 5 because `CMakeGenerate` is interactive (prompts for build type) and can't be driven headlessly.

- [ ] **Step 6: Commit**

```bash
cd ~/.config/nvim && git add lua/plugins/cpp.lua && git commit -m "feat(cpp): add cmake-tools, clangd_extensions, codelldb adapter"
```

---

## Task 3: Add CLion keybindings via `init` hook on cmake-tools.nvim

Keymaps are registered in the `init` function of the existing `cmake-tools.nvim` spec. `init` runs at Neovim startup (before the plugin is loaded), so the keymaps exist globally; lazy.nvim loads `cmake-tools.nvim` on-demand when a `CMake*` command is first invoked, and loads `nvim-dap` when the first `require("dap")` fires inside a debug keymap.

**Files:**
- Modify: `~/.config/nvim/lua/plugins/cpp.lua`

- [ ] **Step 1: Add `init` to the cmake-tools.nvim spec**

Find the `Civitasv/cmake-tools.nvim` block in `cpp.lua`. Insert an `init` field right before its `opts` field. The full block should look like this after the edit:

```lua
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
    init = function()
      local set = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
      end

      -- CMake build/run/debug — these <cmd> invocations lazy-load cmake-tools.nvim
      set("n", "<C-F9>",   "<cmd>CMakeBuild<cr>",                       "CMake: Build")
      set("n", "<S-F10>",  "<cmd>CMakeRun<cr>",                         "CMake: Run")
      set("n", "<S-F9>",   "<cmd>CMakeDebug<cr>",                       "CMake: Debug")
      set("n", "<C-S-F9>", "<cmd>CMakeClean<cr><cmd>CMakeBuild<cr>",    "CMake: Rebuild")
      set("n", "<leader>cm", "<cmd>CMakeSelectBuildTarget<cr>",         "CMake: Select target")

      -- Debugger step commands — require('dap') lazy-loads nvim-dap
      set("n", "<F9>",   function() require("dap").toggle_breakpoint() end, "DAP: Toggle breakpoint")
      set("n", "<F8>",   function() require("dap").step_over() end,         "DAP: Step over")
      set("n", "<F7>",   function() require("dap").step_into() end,         "DAP: Step into")
      set("n", "<S-F8>", function() require("dap").step_out() end,          "DAP: Step out")
    end,
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
```

- [ ] **Step 2: Verify file still parses**

Run: `nvim --headless -c "luafile /home/baz/.config/nvim/lua/plugins/cpp.lua" -c "qa" 2>&1`
Expected: no output.

- [ ] **Step 3: Verify keymaps registered at Neovim startup**

Run: `nvim --headless -c "lua print(vim.fn.maparg('<C-F9>', 'n'))" -c "qa" 2>&1`
Expected: the output contains `CMakeBuild` (the full RHS of the mapping). Proves the mapping is registered globally at startup (without needing to open a C++ file first). If output is empty, the `init` hook did not run — check for Lua errors by starting Neovim normally.

- [ ] **Step 4: Commit**

```bash
cd ~/.config/nvim && git add lua/plugins/cpp.lua && git commit -m "feat(cpp): add CLion-style build/run/debug keymaps"
```

---

## Task 4: Add Complete Statement function to `cpp.lua`

**Files:**
- Modify: `~/.config/nvim/lua/plugins/cpp.lua`

- [ ] **Step 1: Add the function and keymap to the `init` block**

Inside the `init = function()` body from Task 3 (in the `cmake-tools.nvim` spec), **after** the existing `set(...)` calls and **before** the closing `end,`, insert the function definition and its keymap:

```lua
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
```

- [ ] **Step 2: Verify file still parses**

Run: `nvim --headless -c "luafile /home/baz/.config/nvim/lua/plugins/cpp.lua" -c "qa" 2>&1`
Expected: no output.

- [ ] **Step 3: Unit-test the function headlessly**

Create `/tmp/test_complete_stmt.lua` with exactly this content (the function is fully inlined — no paste-from-step-1 needed):

```lua
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
  end
end

local cases = {
  { before = "if (x > 0",                  after_first = "if (x > 0) {",             block_below = true  },
  { before = "foo(a, b",                   after_first = "foo(a, b);",               block_below = false },
  { before = "int x = 5",                  after_first = "int x = 5;",               block_below = false },
  { before = "std::vector<int> v{1,2,3",   after_first = "std::vector<int> v{1,2,3};", block_below = false },
  { before = "else",                       after_first = "else {",                   block_below = true  },
  { before = "if (x) {",                   after_first = "if (x) {",                 block_below = true  },
}

local failures = 0
for _, tc in ipairs(cases) do
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { tc.before })
  vim.api.nvim_win_set_cursor(0, { 1, #tc.before })
  complete_statement()
  local got = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
  local ok = (got == tc.after_first)
  io.write(("%s  %q -> %q  (want %q)\n"):format(ok and "PASS" or "FAIL", tc.before, got or "", tc.after_first))
  if not ok then failures = failures + 1 end
  if tc.block_below then
    local last = vim.api.nvim_buf_get_lines(0, -2, -1, false)[1] or ""
    local ok2 = last:match("^%s*}%s*$") ~= nil
    io.write(("  %s  closing `}` on last line (got %q)\n"):format(ok2 and "PASS" or "FAIL", last))
    if not ok2 then failures = failures + 1 end
  end
end
io.write(failures == 0 and "ALL PASS\n" or (failures .. " failure(s)\n"))
os.exit(failures == 0 and 0 or 1)
```

Run: `nvim --headless --clean -c "luafile /tmp/test_complete_stmt.lua" 2>&1`
Expected: Exit code 0 and final line `ALL PASS`. Every case shows `PASS`. If any `FAIL`, the implementation is wrong — fix before moving on.

- [ ] **Step 4: Manual interactive verification**

```bash
cp /dev/null /tmp/stmt_test.cpp
nvim /tmp/stmt_test.cpp
```

In Neovim:
1. `i` to enter insert mode, type `if (x > 0`, then press `Ctrl+Shift+Enter`.
2. Expected: line becomes `if (x > 0) {`; cursor sits on an indented new line; `}` appears on the line below. Editor is in insert mode.
3. `<Esc>:q!<Enter>` to exit without saving.

- [ ] **Step 5: Commit**

```bash
cd ~/.config/nvim && git add lua/plugins/cpp.lua && git commit -m "feat(cpp): add Ctrl+Shift+Enter Complete Statement"
```

---

## Task 5: End-to-end verification on CS-330 project

**Files:** No changes — this task only runs the system to verify.

- [ ] **Step 1: Open the CS-330 OpenGL sample**

```bash
cd ~/Downloads/CS330Content/Projects/1-2_OpenGLSample
nvim main.cpp
```

- [ ] **Step 2: Verify clangd attached**

In Neovim, run `:LspInfo`
Expected: `clangd` shown as attached to the buffer. Close the info window with `q`.

- [ ] **Step 3: Select a build target**

Press `<leader>cm` (Space then `cm`).
Expected: a picker appears listing CMake targets defined by the project's `CMakeLists.txt`. Pick the main executable.

- [ ] **Step 4: Build**

Press `Ctrl+F9`.
Expected: build output window shows compilation; ends with no errors. If the project requires additional libs (GLFW, GLAD) and they aren't installed, install them first via `pacman` and retry — that's a project-setup issue, not a Neovim config issue.

- [ ] **Step 5: Run**

Press `Shift+F10`.
Expected: an OpenGL window launches. Close it to return to Neovim.

- [ ] **Step 6: Debug**

1. Move cursor to the first line inside `main()` (typically `glfwInit()`).
2. Press `F9` — a red breakpoint marker appears in the sign column.
3. Press `Shift+F9`.
Expected: debug UI panes open (variables, stack, breakpoints). Execution halts at the breakpoint. Press `F8` to step over — you can see lines advance. Continue by running `:lua require('dap').continue()` or pressing your configured continue key. The program finishes normally.

- [ ] **Step 7: Regression check — Lua file highlighting**

```bash
nvim ~/.config/nvim/lua/plugins/cpp.lua
```
Expected: syntax highlighting is visible on first open (this verifies the `init.lua` treesitter race-condition fix is still working).

- [ ] **Step 8: Final commit (if any stray changes)**

```bash
cd ~/.config/nvim && git status --short
```
If only unrelated pre-existing changes show, you're done. If any of our files show as dirty, investigate before committing.

---

## Self-review checklist (for the planner)

- **Spec coverage:**
  - Architecture (dap.core extra + cpp.lua) → Tasks 1–2 ✓
  - All CLion keymaps (`<C-F9>`, `<S-F10>`, `<S-F9>`, `<C-S-F9>`, `<F9>`, `<F8>`, `<F7>`, `<S-F8>`, `<leader>cm`, `<C-S-CR>`) → Task 3 + Task 4 ✓
  - Complete Statement semantics (close brackets, append `;`, block-keyword handling, indent) → Task 4 ✓
  - File changes (`lazyvim.json` + new `cpp.lua`) → Tasks 1, 2 ✓
  - Test plan (LSP attach, build, run, debug, complete statement, regression) → Task 5 ✓
- **Placeholder scan:** no TBDs, every code block is complete verbatim code.
- **Type consistency:** `complete_statement()` signature is identical between Step 1 definition and Step 3 test harness. Commands `CMakeBuild`, `CMakeRun`, `CMakeDebug`, `CMakeClean`, `CMakeSelectBuildTarget` used consistently with cmake-tools.nvim's published command names.
