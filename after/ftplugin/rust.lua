-- Pre-warm treesitter query cache for Rust
if vim.treesitter.language.get_lang("rust") then
  pcall(vim.treesitter.query.get, "rust", "highlights")
  pcall(vim.treesitter.query.get, "rust", "indents")
end
