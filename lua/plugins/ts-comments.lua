-- Enhanced ts-comments.nvim configuration for robust multi-language support
-- This plugin patches vim.filetype.get_option to provide context-aware commentstrings
-- using treesitter, ensuring correct comments for Rust, C++, Python, JavaScript, etc.
return {
  "folke/ts-comments.nvim",
  opts = {
    lang = {
      -- Ensure Rust has robust comment support (both single-line and block)
      rust = { "// %s", "/* %s */" },
      
      -- C/C++ languages
      c = { "// %s", "/* %s */" },
      cpp = { "// %s", "/* %s */" },
      
      -- TypeScript/JavaScript with JSX support
      typescript = { "// %s", "/* %s */" },
      javascript = {
        "// %s",
        "/* %s */",
        call_expression = "// %s",
        jsx_attribute = "// %s",
        jsx_element = "{/* %s */}",
        jsx_fragment = "{/* %s */}",
        spread_element = "// %s",
        statement_block = "// %s",
      },
      tsx = {
        "// %s",
        "/* %s */",
        call_expression = "// %s",
        jsx_attribute = "// %s",
        jsx_element = "{/* %s */}",
        jsx_fragment = "{/* %s */}",
        spread_element = "// %s",
        statement_block = "// %s",
      },
      
      -- Python
      python = "# %s",
      
      -- Lua
      lua = "-- %s",
      
      -- Shell scripting
      bash = "# %s",
      sh = "# %s",
      zsh = "# %s",
      
      -- Web technologies
      html = "<!-- %s -->",
      css = { "/* %s */", "// %s" },
      scss = { "// %s", "/* %s */" },
      
      -- Markdown
      markdown = "<!-- %s -->",
      
      -- YAML/TOML
      yaml = "# %s",
      toml = "# %s",
      
      -- JSON (uses jsonc for comments)
      json = "// %s",
      jsonc = "// %s",
      
      -- Go
      go = "// %s",
      
      -- Java/Kotlin
      java = "// %s",
      kotlin = "// %s",
      
      -- Swift
      swift = "// %s",
      
      -- PHP
      php = "// %s",
      
      -- Ruby
      ruby = "# %s",
      
      -- SQL
      sql = "-- %s",
      
      -- Vim
      vim = "\" %s",
      
      -- Nix
      nix = "# %s",
      
      -- Haskell
      haskell = "-- %s",
      
      -- Elixir
      elixir = "# %s",
      
      -- Zig
      zig = "// %s",
      
      -- OCaml
      ocaml = "(* %s *)",
    },
  },
}
