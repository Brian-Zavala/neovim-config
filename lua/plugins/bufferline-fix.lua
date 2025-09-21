-- Store base options globally to preserve them across theme changes
vim.g.bufferline_base_opts = vim.g.bufferline_base_opts or {}

return {
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function(_, opts)
      -- Store base options for later use
      vim.g.bufferline_base_opts = vim.tbl_deep_extend("force", vim.g.bufferline_base_opts, opts or {})
      
      -- Dynamic theme integration support
      local function get_theme_highlights()
        local theme_name = vim.g.colors_name or ""
        
        -- Return early if no theme is set
        if theme_name == "" then
          return nil
        end
        
        -- Try to load theme-specific bufferline integration
        local integrations = {
          -- Catppuccin (exact match to avoid false positives)
          ["^catppuccin"] = function()
            local ok, module = pcall(require, "catppuccin.groups.integrations.bufferline")
            if ok and module then
              -- Try get_theme first (correct method name), then fall back to get
              if type(module.get_theme) == "function" then
                local success, highlights = pcall(module.get_theme)
                if success then
                  return highlights
                end
              elseif type(module.get) == "function" then
                local success, highlights = pcall(module.get)
                if success then
                  return highlights
                end
              end
            end
            return nil
          end,
          -- TokyoNight
          ["^tokyonight"] = function()
            -- TokyoNight has good auto-detection, no special handling needed
            return nil
          end,
          -- Gruvbox
          ["^gruvbox"] = function()
            -- Gruvbox works well with default bufferline color detection
            return nil
          end,
        }
        
        -- Check each integration with pattern matching
        for pattern, loader in pairs(integrations) do
          if theme_name:match(pattern) then
            local result = loader()
            if result then
              return result
            end
            -- Break after first match to avoid multiple pattern matches
            break
          end
        end
        
        -- Return nil to use bufferline's automatic theme detection
        return nil
      end
      
      -- Function to update bufferline with current theme
      local function update_bufferline_theme()
        -- Get base options from global storage
        local base_opts = vim.deepcopy(vim.g.bufferline_base_opts or {})
        
        -- Get theme-specific highlights
        local highlights = get_theme_highlights()
        
        if highlights then
          base_opts.highlights = highlights
        else
          -- Remove highlights to let bufferline auto-detect
          base_opts.highlights = nil
        end
        
        -- Safe call to setup with error handling
        local ok, bufferline = pcall(require, "bufferline")
        if ok and bufferline then
          local setup_ok, err = pcall(bufferline.setup, base_opts)
          if not setup_ok then
            vim.notify("Bufferline setup error: " .. tostring(err), vim.log.levels.WARN)
          end
        end
      end
      
      -- Set initial highlights
      local initial_highlights = get_theme_highlights()
      if initial_highlights then
        opts.highlights = initial_highlights
      end
      
      -- Initialize bufferline with options
      require("bufferline").setup(opts)
      
      -- Create autocmd group outside to prevent duplication
      local group_theme = vim.api.nvim_create_augroup("BufferlineThemeSync", { clear = true })
      local group_omarchy = vim.api.nvim_create_augroup("BufferlineOmarchySync", { clear = true })
      
      -- Auto-update on colorscheme changes
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = group_theme,
        callback = function()
          -- Defer to next tick to ensure theme is fully loaded
          vim.defer_fn(update_bufferline_theme, 1)
        end,
        desc = "Update bufferline colors when colorscheme changes"
      })
      
      -- Listen for User events that theme switchers might trigger
      vim.api.nvim_create_autocmd("User", {
        pattern = { "ThemeChanged", "OmarchyThemeChanged", "ThemeSwitched" },
        group = group_omarchy,
        callback = function()
          vim.defer_fn(update_bufferline_theme, 1)
        end,
        desc = "Update bufferline for omarchy 2.0 theme changes"
      })
      
      -- Also listen for OptionSet in case colors_name is set directly
      vim.api.nvim_create_autocmd("OptionSet", {
        pattern = "background",
        group = group_theme,
        callback = function()
          vim.defer_fn(update_bufferline_theme, 1)
        end,
        desc = "Update bufferline when background option changes"
      })
    end,
  },
}