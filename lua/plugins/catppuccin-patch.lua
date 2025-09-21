-- Monkey-patch catppuccin bufferline integration to fix LazyVim compatibility
-- LazyVim expects .get() but catppuccin provides .get_theme()
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 2000, -- Higher priority to run before other configs
    init = function()
      -- Patch the module before LazyVim tries to use it
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyLoad",
        once = true,
        callback = function(args)
          if args.data == "catppuccin" then
            -- Wait for catppuccin to load
            vim.defer_fn(function()
              local ok, bufferline_integration = pcall(require, "catppuccin.groups.integrations.bufferline")
              if ok and bufferline_integration then
                -- Add the missing .get() method that LazyVim expects
                if not bufferline_integration.get and bufferline_integration.get_theme then
                  bufferline_integration.get = bufferline_integration.get_theme
                end
              end
            end, 1)
          end
        end,
      })
      
      -- Also patch immediately if catppuccin is already loaded
      local ok, bufferline_integration = pcall(require, "catppuccin.groups.integrations.bufferline")
      if ok and bufferline_integration then
        if not bufferline_integration.get and bufferline_integration.get_theme then
          bufferline_integration.get = bufferline_integration.get_theme
        end
      end
    end,
    config = function(_, opts)
      -- Ensure the patch is applied before setup
      local ok, bufferline_integration = pcall(require, "catppuccin.groups.integrations.bufferline")
      if ok and bufferline_integration then
        if not bufferline_integration.get and bufferline_integration.get_theme then
          bufferline_integration.get = bufferline_integration.get_theme
        end
      end
      
      require("catppuccin").setup(opts)
    end,
  },
}