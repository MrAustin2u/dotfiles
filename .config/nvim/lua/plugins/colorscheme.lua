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
    specs = {
      {
        "akinsho/bufferline.nvim",
        opts = function(_, opts)
          if (vim.g.colors_name or ""):find "catppuccin" then
            opts.highlights = require("catppuccin.groups.integrations.bufferline").get()
          end
        end,
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
      dim_inactive = true,
      hide_inactive_statusline = true,
      on_highlights = function(hl, c)
        hl.DapBreakpoint = {
          fg = c.red,
        }
        hl.DapLogPoint = {
          fg = c.blue5,
        }
        hl.DapStopped = {
          fg = c.green1,
        }
      end,
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
      transparent = true,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd [[colorscheme tokyonight-moon]]
    end,
  },
}
