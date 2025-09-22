-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--
--
-- Terminal opener that cds into the current file's directory

-- Always enter insert mode when opening a terminal
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function()
    vim.cmd("startinsert")
  end,
})

-- Helper: choose directory (file's dir if available; otherwise cwd)
local function term_dir()
  local d = vim.fn.expand("%:p:h")
  return (d ~= "" and d) or vim.fn.getcwd()
end

_G.TermHereToggle = function()
  local state = vim.t.termhere_state or {}
  local buf = state.buf
  local dir = term_dir()

  -- If buffer exists and is valid
  if buf and vim.api.nvim_buf_is_valid(buf) then
    local wins = vim.fn.win_findbuf(buf)
    -- If window is visible, just close the window (keep buffer)
    if wins[1] and vim.api.nvim_win_is_valid(wins[1]) then
      vim.api.nvim_win_close(wins[1], false)
      -- Don't delete buffer or clear state - we want to reuse it
      return
    else
      -- Buffer exists but no window - reopen it
      vim.cmd("belowright split")
      vim.api.nvim_win_set_buf(0, buf)
      vim.cmd("startinsert")
      return
    end
  end

  -- No existing buffer - create new terminal
  local orig_win = vim.api.nvim_get_current_win()
  vim.cmd("lcd " .. vim.fn.fnameescape(dir)) -- set cwd for this window
  vim.cmd("belowright split | terminal") -- terminal inherits cwd
  vim.cmd("lcd -") -- restore original window's cwd

  local term_win = vim.api.nvim_get_current_win()
  buf = vim.api.nvim_get_current_buf()

  -- Make it unlisted so it doesn't clutter :ls
  vim.bo[buf].buflisted = false

  -- Clear state when the job ends (terminal process exits)
  vim.api.nvim_create_autocmd("TermClose", {
    buffer = buf,
    once = true,
    callback = function()
      -- Only clear state when terminal process actually ends
      if vim.t.termhere_state and vim.t.termhere_state.buf == buf then
        vim.t.termhere_state = nil
      end
    end,
  })


  -- Save tab-local state
  vim.t.termhere_state = { buf = buf, win = term_win }
end

-- Autosave all buffers when switching buffers or losing focus
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost" }, {
  pattern = "*",
  callback = function()
    vim.cmd("silent! wall")
  end,
})

-- Auto-format on save, buffer leave, and focus lost
vim.api.nvim_create_autocmd({ "BufWritePost", "BufLeave", "FocusLost" }, {
  pattern = "*",
  callback = function(args)
    -- Check if conform is available
    local ok, conform = pcall(require, "conform")
    if not ok then
      return
    end

    -- Only format if the buffer is a normal file buffer
    local buftype = vim.bo[args.buf].buftype
    if buftype ~= "" and buftype ~= "acwrite" then
      return
    end

    -- Format the buffer
    conform.format({
      bufnr = args.buf,
      async = true,
      lsp_fallback = true,
      quiet = true,
    })
  end,
})

-- Auto LazySync when Neovim config files are changed
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.lua", "*.vim" },
  callback = function(args)
    local file = vim.fn.expand("%:p")
    -- Check if the file is in the Neovim config directory
    if file:match("%.config/nvim/") then
      -- Check if it's a plugin configuration file
      if file:match("/plugins/") or file:match("lazy%-lock%.json") then
        -- Run LazySync asynchronously
        vim.defer_fn(function()
          vim.notify("Config changed, syncing plugins...", vim.log.levels.INFO)
          vim.cmd("LazySync")
        end, 100)
      end
    end
  end,
})
