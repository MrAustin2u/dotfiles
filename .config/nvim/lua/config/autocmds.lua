return {
  {
    name = "FileTypeOptions",
    {
      "FileType",
      function()
        vim.opt_local.wrap = true
        vim.opt_local.spell = true
      end,
      opts = { pattern = { "gitcommit", "markdown" } },
    },
    {
      "FileType",
      function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
      end,
      opts = {
        pattern = {
          "PlenaryTestPopup",
          "checkhealth",
          "grug-far",
          "help",
          "lspinfo",
          "man",
          "notify",
          "qf",
          "query",
          "spectre_panel",
          "startuptime",
          "tsplayground",
        },
      },
    },
  },
  {
    name = "LastLocation",
    {
      "BufReadPost",
      function(event)
        local exclude = { "gitcommit" }
        local buf = event.buf
        if vim.tbl_contains(exclude, vim.bo[buf].filetype) then
          return
        end
        local mark = vim.api.nvim_buf_get_mark(buf, '"')
        local lcount = vim.api.nvim_buf_line_count(buf)
        if mark[1] > 0 and mark[1] <= lcount then
          pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
      end,
      opts = { pattern = "*" },
    },
  },
  {
    name = "HighlightYank",
    {
      "TextYankPost",
      function()
        vim.highlight.on_yank()
      end,
      opts = { pattern = "*" },
    },
  },

  {
    name = "CheckTime",
    {
      { "FocusGained", "TermClose", "TermLeave" },
      "checktime",
      opts = { pattern = "*" },
    },
  },
}
