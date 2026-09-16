-- Pre-warm treesitter query cache for Python
-- This makes the first Python file open slightly faster
if vim.treesitter.language.get_lang("python") then
  pcall(vim.treesitter.query.get, "python", "highlights")
  pcall(vim.treesitter.query.get, "python", "indents")
end
