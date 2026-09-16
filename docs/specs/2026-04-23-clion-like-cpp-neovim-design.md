# CLion-like C++ Development in Neovim — Design

**Author:** Brian Zavala
**Date:** 2026-04-23
**Target:** Arch Linux, kitty, Neovim 0.12.1 with existing LazyVim at `~/.config/nvim/`.

## Goal

Make Neovim feel like CLion for the CS-330 OpenGL projects (`~/Downloads/CS330Content/Projects/*`, all CMake-based):

- Build current target with a keypress.
- Build + run with a keypress.
- Build + run under a debugger with breakpoints, stepping, variable inspection.
- `Ctrl+Shift+Enter` completes the current statement: close unclosed brackets, append `;`, drop to a new line.

## Architecture

Three layers on top of the existing LazyVim config:

| Layer | Source | Role |
|---|---|---|
| `dap.core` LazyVim extra | `lazyvim.json` | Pulls in `nvim-dap`, `nvim-dap-ui`, `mason-nvim-dap` (no LSP overlap — does not touch the existing custom clangd setup in `lsp.lua`) |
| `cpp.lua` plugin file | new file | `cmake-tools.nvim` + `clangd_extensions.nvim` + codelldb adapter config + CLion keymaps + complete-statement function |
| Mason | existing | Ensures `codelldb` binary is installed (specified via `ensure_installed` in the plugin spec) |

The existing custom clangd config at `lsp.lua:115-132` is left untouched (keeps the user's `--background-index`, `--clang-tidy`, `--header-insertion=iwyu`, `--function-arg-placeholders` flags).

**Debug flow (Shift+F9):** `cmake-tools.nvim` runs `:CMakeDebug` → builds the selected CMake target → hands the binary to `nvim-dap` → `nvim-dap` launches `codelldb` via the adapter configured in `cpp.lua` → `nvim-dap-ui` opens debug panels.

Neovim 0.12.1 + kitty auto-negotiate the kitty keyboard protocol at startup, so `Ctrl+Shift+Enter` reaches Neovim with no terminal-side config.

## Keybindings

| CLion | Neovim | Action |
|---|---|---|
| Ctrl+F9 | `<C-F9>` | `:CMakeBuild` |
| Shift+F10 | `<S-F10>` | `:CMakeRun` |
| Shift+F9 | `<S-F9>` | `:CMakeDebug` |
| Ctrl+Shift+F9 | `<C-S-F9>` | `:CMakeClean` then `:CMakeBuild` |
| F9 | `<F9>` | `dap.toggle_breakpoint()` |
| F8 / F7 / Shift+F8 | `<F8>` / `<F7>` / `<S-F8>` | Step over / into / out |
| — | `<leader>cm` | `:CMakeSelectBuildTarget` (CMake target picker) |
| Ctrl+Shift+Enter | `<C-S-CR>` | Complete Statement (see below) |

## Complete Statement (`<C-S-CR>`)

A Lua function in `~/.config/nvim/lua/plugins/cpp.lua`, mapped in normal and insert modes. Logic:

1. Scan the current line left-to-right, tracking unmatched `(`, `[`, `{` while skipping bracket characters inside `"..."` string literals and `//` line comments.
2. Append the required closing brackets (in reverse order) to the end of the line. Exception: a trailing unmatched `{` introduces a block and is left alone.
3. If the resulting line doesn't end in `;` or `{`, append `;`.
4. Execute `o` (open a new indented line below) and enter insert mode.

### Examples

```
if (x > 0|          →   if (x > 0) {
                            |
                        }

foo(a, b|           →   foo(a, b);
                        |

int x = 5|          →   int x = 5;
                        |
```

### Accepted limitations

Single-line scan only. Multi-line template instantiations, raw string literals, or deeply nested lambdas may close incorrectly — user presses `u` and finishes manually in those rare cases.

## File changes

| Path | Change |
|---|---|
| `~/.config/nvim/lazyvim.json` | Add `"lazyvim.plugins.extras.dap.core"` to the `extras` array |
| `~/.config/nvim/lua/plugins/cpp.lua` | **New** — `cmake-tools.nvim` spec, `clangd_extensions.nvim` spec, codelldb adapter config, Mason `ensure_installed` entry for `codelldb`, keymaps, complete-statement function |

No system packages, no manual Mason commands (ensure_installed handles it), no kitty config.

## Test plan

Run against `~/Downloads/CS330Content/Projects/1-2_OpenGLSample/`:

1. Open `main.cpp` → clangd attaches (shown in `:LspInfo`), hover works, go-to-def works.
2. `<C-F9>` → build succeeds, quickfix/terminal shows output.
3. `<S-F10>` → OpenGL window appears.
4. Set breakpoint with `<F9>` after `glfwInit()`, press `<S-F9>` → execution pauses, DAP UI shows stack and locals; `<F8>` steps over; continue finishes the program.
5. In `main.cpp`, type `if (x > 0` with cursor after `0`, press `<C-S-CR>` → becomes `if (x > 0) {` with cursor on indented new line. Repeat for `foo(a, b` → `foo(a, b);`.
6. Open a Lua file → syntax highlighting on first open (verifies the existing `init.lua` race-condition fix is preserved).
