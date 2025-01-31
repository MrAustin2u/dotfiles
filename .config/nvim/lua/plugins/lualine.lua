return {
  "nvim-lualine/lualine.nvim",
  opts = {
    options = {
      theme = "auto",
      disabled_filetypes = {
        "TelescopePrompt",
        "TelescopeResults",
        statusline = { "snacks_dashboard", "starter" },
      },
      component_separators = "|",
      section_separators = { left = "", right = "" },
      globalstatus = true,
    },
    sections = {
      lualine_a = {
        { "mode", separator = { left = "" }, right_padding = 2 },
      },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = { { "filename", path = 1 } },
      lualine_x = {
        {
          require("lazy.status").updates,
          cond = require("lazy.status").has_updates,
          color = { bg = "none", fg = "#ff966c" },
        },
      },
      lualine_y = { "filetype", "progress" },
      lualine_z = {
        { "location", separator = { right = "" }, left_padding = 2 },
      },
    },
    extensions = { "neo-tree", "lazy" },
  },
}
