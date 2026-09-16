-- Simple external image viewer for image files
-- Opens images in system default viewer when clicked/opened from Neo-tree

vim.api.nvim_create_autocmd({"BufReadPost", "BufNewFile"}, {
  pattern = {"*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.bmp", "*.svg", "*.ico"},
  callback = function(args)
    local filepath = vim.fn.expand("%:p")
    local filename = vim.fn.expand("%:t")
    
    -- Clear the buffer and show info
    vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, {
      "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
      "         🖼️  Image Viewer",
      "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
      "",
      "File: " .. filename,
      "Path: " .. filepath,
      "Size: " .. vim.fn.getfsize(filepath) .. " bytes",
      "",
      "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
      "Press <Enter> to open in external viewer",
      "Press q to close this buffer",
      "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    })
    
    -- Make buffer non-modifiable
    vim.bo[args.buf].modifiable = false
    vim.bo[args.buf].buftype = "nofile"
    
    -- Auto-open in external viewer
    vim.defer_fn(function()
      vim.fn.system('xdg-open "' .. filepath .. '" &')
      vim.notify("Opened " .. filename .. " in external viewer", vim.log.levels.INFO)
    end, 100)
    
    -- Key mappings
    vim.keymap.set('n', '<CR>', function()
      vim.fn.system('xdg-open "' .. filepath .. '" &')
      vim.notify("Opening in external viewer", vim.log.levels.INFO)
    end, { buffer = args.buf, desc = "Open image in external viewer" })
    
    vim.keymap.set('n', 'q', '<cmd>bdelete<CR>', { buffer = args.buf, desc = "Close image buffer" })
  end
})

return {}