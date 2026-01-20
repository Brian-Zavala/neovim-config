-- Pre-warm treesitter query cache for C++
if vim.treesitter.language.get_lang("cpp") then
  pcall(vim.treesitter.query.get, "cpp", "highlights")
  pcall(vim.treesitter.query.get, "cpp", "indents")
end
