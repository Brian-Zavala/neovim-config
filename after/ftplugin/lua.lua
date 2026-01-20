-- Pre-warm treesitter query cache for Lua
if vim.treesitter.language.get_lang("lua") then
  pcall(vim.treesitter.query.get, "lua", "highlights")
  pcall(vim.treesitter.query.get, "lua", "indents")
end
