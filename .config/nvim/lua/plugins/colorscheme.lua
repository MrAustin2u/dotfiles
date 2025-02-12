return {
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    opts = {
      integrations = {
        aerial = true,
        cmp = true,
        snacks_dashboard = true,
        flash = true,
        gitsigns = true,
        headlines = true,
        illuminate = true,
        indent_blankline = { enabled = true },
        leap = true,
        lsp_trouble = true,
        mason = true,
        markdown = true,
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
        navic = { enabled = true, custom_bg = "lualine" },
        neotest = true,
        neotree = true,
        noice = true,
        notify = true,
        semantic_tokens = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
      },
    },
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      plugins = { markdown = true },
      tokyonight_dark_float = false,
      on_highlights = function(hl, c)
        hl.CursorLineNr = {
          fg = c.orange,
          bold = true,
        }
        hl.LineNrAbove = { fg = c.fg_gutter }
        hl.LineNrBelow = { fg = c.fg_gutter }
        local prompt = "#2d3149"
        hl.TelescopeNormal = { bg = c.bg_dark, fg = c.fg_dark }
        hl.TelescopeBorder = { bg = c.bg_dark, fg = c.bg_dark }
        hl.TelescopePromptNormal = { bg = prompt }
        hl.TelescopePromptBorder = { bg = prompt, fg = prompt }
        hl.TelescopePromptTitle = { bg = c.fg_gutter, fg = c.orange }
        hl.TelescopePreviewTitle = { bg = c.bg_dark, fg = c.bg_dark }
        hl.TelescopeResultsTitle = { bg = c.bg_dark, fg = c.bg_dark }
      end,
      dim_inactive = true,
      hide_inactive_statusline = true,
      sidebars = {
        "qf",
        "vista_kind",
        "terminal",
        "spectre_panel",
        "grug_far",
        "startuptime",
        "Outline",
      },
      style = "moon",
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      transparent = true,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)

      vim.cmd [[colorscheme tokyonight]]
      vim.cmd [[hi TabLine guibg=NONE guifg=NONE]]
      vim.cmd [[hi WinBar guibg=NONE guifg=NONE]]
      vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
    end,
  },
}
