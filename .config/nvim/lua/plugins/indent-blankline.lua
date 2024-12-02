return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local ibl = require "ibl"

    ibl.setup {
      indent = { char = "│", tab_char = "│" },
      scope = {
        show_start = false,
        show_end = false,
        enabled = false,
      },
      exclude = {
        buftypes = { "NvimTree", "TelescopePrompt" },
        filetypes = {
          "snacks_dashboard",
          "lazy",
          "lazyterm",
          "lspinfo",
          "man",
          "mason",
          "neo-tree",
          "notify",
          "qf",
        },
      },
    }
  end,
}
