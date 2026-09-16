-- Guard against an upstream Neovim bug: the inlay-hint decoration provider
-- crashes with `Invalid 'col': out of range` when a cached hint references a
-- column beyond the current line length. This happens with stale hint versions
-- after edits, and is much more likely with multiple LSP clients attached to
-- the same buffer (e.g. ts_ls + vtsls, or duplicate clangd clients).
--
-- Upstream issues:
--   https://github.com/neovim/neovim/issues/39772
--   https://github.com/neovim/neovim/issues/36318
--
-- What this does: intercept inline virtual-text extmarks written to the
-- `nvim.lsp.inlayhint` namespace, bounds-check them against the current line,
-- and silently skip stale hints instead of letting the error spam popups.
-- All other extmark callers take the fast path untouched.
--
-- Safe to delete once the installed Neovim runtime bounds-checks (or skips)
-- out-of-range hints in `runtime/lua/vim/lsp/inlay_hint.lua` itself.

local api = vim.api

-- Resolving is idempotent: the same name always yields the same id, so this
-- matches the namespace the runtime uses even though we create it here.
local inlay_ns = api.nvim_create_namespace("nvim.lsp.inlayhint")

-- Reference to the original C-backed implementation (no recursion: the
-- runtime captured the `vim.api` table, so it dispatches through this
-- wrapper, while we call the saved original directly).
local orig_set_extmark = api.nvim_buf_set_extmark

---@diagnostic disable-next-line: duplicate-set-field
function api.nvim_buf_set_extmark(bufnr, ns_id, line, col, opts)
  -- Only intercept inline virtual-text writes from the inlay-hint provider.
  if ns_id == inlay_ns and type(opts) == "table" and opts.virt_text_pos == "inline" then
    local buf = (bufnr == 0) and api.nvim_get_current_buf() or bufnr
    if not api.nvim_buf_is_valid(buf) then
      return nil
    end
    local ok_count, line_count = pcall(api.nvim_buf_line_count, buf)
    if not ok_count or line < 0 or line >= line_count then
      return nil
    end
    local ok_line, lines = pcall(api.nvim_buf_get_lines, buf, line, line + 1, false)
    local line_len = (ok_line and lines and lines[1] and #lines[1]) or 0
    if col < 0 or col > line_len then
      -- Stale hint (line shortened since the LSP response). Skip it; the
      -- next inlay-hint refresh provides up-to-date positions.
      return nil
    end
    -- Bounds looked fine, but the buffer may have changed between the check
    -- and the write, so never let this throw inside a decoration provider.
    local ok_mark, mark_id = pcall(orig_set_extmark, bufnr, ns_id, line, col, opts)
    if ok_mark then
      return mark_id
    end
    return nil
  end
  return orig_set_extmark(bufnr, ns_id, line, col, opts)
end
