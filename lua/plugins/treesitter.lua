return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- Explicitly prevent lazy loading (belt-and-suspenders with syntax enable)
    lazy = false,
    
    opts = function(_, opts)
      -- Add Omarchy 3.0+ custom languages to LazyVim's defaults
      vim.list_extend(opts.ensure_installed, {
        "rust",
        "cpp",
        "css",
      })
      
      -- Custom incremental selection keymaps
      opts.incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      }
      
      return opts
    end,
    
    -- Health check: Verify critical parsers are installed
    init = function()
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          -- Wait for lazy.nvim to finish loading
          vim.defer_fn(function()
            local ok, TS = pcall(require, "nvim-treesitter")
            if not ok then return end
            
            local installed = TS.get_installed()
            local critical = {"python", "lua", "rust", "cpp", "css", "javascript", "typescript"}
            local missing = {}
            
            for _, lang in ipairs(critical) do
              if not vim.tbl_contains(installed, lang) then
                table.insert(missing, lang)
              end
            end
            
            if #missing > 0 then
              vim.notify(
                "⚠️  Missing Treesitter parsers: " .. table.concat(missing, ", ") .. "\nRun :TSInstall to fix.",
                vim.log.levels.WARN,
                { title = "Treesitter Health Check" }
              )
            end
          end, 1000) -- 1 second delay to ensure lazy.nvim is done
        end,
        once = true,
      })
    end,
  },
}
