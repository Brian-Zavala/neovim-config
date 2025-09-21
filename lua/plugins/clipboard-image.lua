return {
  "ekickx/clipboard-image.nvim",
  cmd = "PasteImg",
  keys = {
    { "<leader>p", "<cmd>PasteImg<cr>", desc = "Paste image from clipboard" },
  },
  opts = {
    default = {
      img_dir = function()
        -- Use images directory relative to current file
        return vim.fn.expand("%:p:h") .. "/images"
      end,
      img_dir_txt = "images",
      img_name = function()
        return os.date('%Y%m%d-%H%M%S')
      end,
      img_handler = function(img)
        -- Auto create directory if it doesn't exist
        local dir = vim.fn.expand("%:p:h") .. "/images"
        if vim.fn.isdirectory(dir) == 0 then
          vim.fn.mkdir(dir, "p")
        end
        
        -- Notify user
        vim.notify("Image pasted: " .. img.name, vim.log.levels.INFO)
      end,
      affix = "%s"
    },
    markdown = {
      affix = "![](%s)",
      img_dir = function()
        return vim.fn.expand("%:p:h") .. "/images"
      end,
      img_dir_txt = "images"
    },
    html = {
      affix = '<img src="%s" alt="image">',
    },
    tex = {
      affix = "\\includegraphics{%s}",
    },
    org = {
      affix = "[[file:%s]]",
    },
    rst = {
      affix = ".. image:: %s",
    }
  }
}