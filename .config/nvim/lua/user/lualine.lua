local M = {
  "nvim-lualine/lualine.nvim",
  opts = {
    options = {
      theme = "auto",
      disabled_filetypes = {
        "TelescopePrompt",
        "TelescopeResults",
        statusline = { "dashboard", "alpha", "starter" },
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
      lualine_c = { 'filename', function() return require('lsp-progress').progress() end },
      lualine_x = {
        {
          require("lazy.status").updates,
          cond = require("lazy.status").has_updates,
          color = { bg = "none", fg = "#ff966c" },
        },
      },
      lualine_y = { 'filetype', 'progress' },
      lualine_z = {
        { "location", separator = { right = "" }, left_padding = 2 },
      },
    },
    extensions = { "neo-tree", "lazy" },
  },
}

function M.config(_, opts)
  require("lualine").setup(opts)
end

return M
