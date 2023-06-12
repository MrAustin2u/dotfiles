return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  version = false, -- telescope did only one release, so use HEAD for now
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-telescope/telescope-file-browser.nvim",
    "olacin/telescope-cc.nvim",
    "m-demare/attempt.nvim",
    "nvim-telescope/telescope-github.nvim",
    "folke/tokyonight.nvim",
  },
  config = function()
    local telescope = require("telescope")

    local opts = {
      defaults = {
        layout_config = {
          center = { width = 0.8 },
        },
      },
      pickers = {
        find_files = {
          theme = "ivy",
          prompt_prefix = " ",
          previewer = false,
        },
        live_grep = {
          prompt_prefix = " ",
        },
      },
      extensions = {
        persisted = {
          layout_config = { width = 0.55, height = 0.55 },
        },
      },
    }

    local apply_highlights = function()
      local colors = require("tokyonight.colors").setup({})
      local util = require("tokyonight.util")
      -- not sure why lua ls cannot see this field.. it's there..
      ---@diagnostic disable-next-line: undefined-field
      local results_bg = util.darken(colors.bg_highlight, 0.2)

      local TelescopePrompt = {
        TelescopePreviewNormal = {
          bg = util.darken(colors.bg_dark, 0.8),
        },
        TelescopePreviewBorder = {
          bg = util.darken(colors.bg_dark, 0.8),
        },
        TelescopePromptNormal = {
          bg = "#2d3149",
        },
        TelescopePromptBorder = {
          bg = "#2d3149",
        },
        TelescopePromptTitle = {
          fg = util.lighten("#2d3149", 0.8),
          bg = "#2d3149",
        },
        TelescopePreviewTitle = {
          fg = colors.info,
          bg = colors.bg_dark,
        },
        TelescopeResultsTitle = {
          fg = colors.bg_dark,
          bg = results_bg,
        },
        TelescopeResultsNormal = {
          bg = results_bg,
        },
        TelescopeResultsBorder = {
          bg = results_bg,
        },
      }

      for hl, col in pairs(TelescopePrompt) do
        vim.api.nvim_set_hl(0, hl, col)
      end
    end

    ---@diagnostic disable-next-line: redundant-parameter
    telescope.setup(opts)

    local extensions = {
      "gh",
      "file_browser",
      "fzf",
      "conventional_commits",
      "attempt",
    }

    for _, e in ipairs(extensions) do
      telescope.load_extension(e)
    end

    apply_highlights()

    require("keymaps").telescope_mappings()
  end,
}
