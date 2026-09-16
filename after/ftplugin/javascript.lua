-- Pre-warm treesitter query cache for JavaScript
if vim.treesitter.language.get_lang("javascript") then
  pcall(vim.treesitter.query.get, "javascript", "highlights")
  pcall(vim.treesitter.query.get, "javascript", "indents")
end
