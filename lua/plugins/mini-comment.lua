return {
  "nvim-mini/mini.comment",
  opts = {
    options = {
      -- Don't ignore blank lines - add comment markers to them
      ignore_blank_line = false,
      -- Start comment at the beginning of the line
      start_of_line = false,
      -- Add padding to comment markers
      pad_comment_parts = true,
    },
  },
}