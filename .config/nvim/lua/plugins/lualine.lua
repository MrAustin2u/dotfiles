return {
  "nvim-lualine/lualine.nvim",
  config = function()
    local tokyonight = require "lualine.themes.tokyonight-moon"
    tokyonight.normal.c.bg = "none"

    require("lualine").setup {
      options = {
        theme = tokyonight,
        disabled_filetypes = {
          "oil",
          "alpha",
          "TelescopePrompt",
          "TelescopeResults",
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
        lualine_c = {
          {
            "filename",
            -- path options:
            -- 0: Just the filename
            -- 1: Relative path
            -- 2: Absolute path
            -- 3: Absolute path, with tilde as the home directory
            -- 4: Filename and parent dir, with tilde as the home directory
            path = 3,
          },
          function()
            return require("lsp-progress").progress()
          end,
        },
        lualine_x = {
          {
            require("lazy.status").updates,
            cond = require("lazy.status").has_updates,
            color = { bg = "none", fg = "#ff966c" },
            { require "mcphub.extensions.lualine" },
          },
        },
        lualine_y = { "filetype", "progress" },
        lualine_z = {
          { "location", separator = { right = "" }, left_padding = 2 },
        },
      },
    }
  end,
}
