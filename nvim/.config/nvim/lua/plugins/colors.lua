return {
  -- colorscheme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        dim_inactive = true,
        hide_inactive_statusline = true,
        style = "moon",
        styles = {
          sidebars = "transparent",
          floats = "transparent",
        },
        transparent = true,
      })

      vim.cmd([[colorscheme tokyonight]])
      vim.cmd([[hi TabLine guibg=NONE guifg=NONE]])
    end,
  },
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    opts = {
      integrations = {
        alpha = true,
        cmp = true,
        gitsigns = true,
        illuminate = true,
        -- indent_blankline = { enabled = true },
        lsp_trouble = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        neotest = true,
        noice = true,
        notify = true,
        nvimtree = true,
        semantic_tokens = true,
        telescope = true,
        treesitter = true,
        which_key = true,
      },
    },
  },
  -- highlight color hex codes with their color (fast!)
  {
    "norcalli/nvim-colorizer.lua",
    event = "VeryLazy",
    opts = {
      "*",
      "!lazy",
    },
  },
}
