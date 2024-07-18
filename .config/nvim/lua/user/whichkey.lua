local M = {
  "folke/which-key.nvim",
  event = "VeryLazy",
}

function M.config()
  local wk = require "which-key"

  wk.add {
    mode = { "n", "v" },
    { "<leader>q", group = "quit/session" },
    { "<leader>s", group = "search" },
    { "<leader>sn", group = "noice" },
    { "<leader>u", group = "ui" },
    { "<leader>t", group = "test" },
    { "<leader>w", group = "windows" },
    { "<leader>x", group = "diagnostics/quickfix" },
    { "[", group = "prev" },
    { "]", group = "next" },
    { "g", group = "goto" },
    { "gz", group = "surround" },
    { "<leader><tab>", group = "tabs" },
    { "<leader>b", group = "buffer" },
    { "<leader>c", group = "code" },
    { "<leader>f", group = "file/find" },
    { "<leader>g", group = "git" },
    { "<leader>gh", group = "hunks" },
  }
end

return M
