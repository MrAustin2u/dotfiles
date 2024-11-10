return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  version = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make", lazy = true },
    "nvim-telescope/telescope-file-browser.nvim",
  },
  keys = function()
    local builtin = require "telescope.builtin"
    require("config.keymaps").telescope_mappings(builtin)
  end,
  opts = function()
    return {
      defaults = {
        -- layout_config = {
        --   center = { width = 0.8 },
        -- },
        entry_prefix = "  ",
        prompt_prefix = "   ",
        selection_caret = "  ",
        color_devicons = true,
        path_display = { "smart" },
        dynamic_preview_title = true,
        layout_config = {
          horizontal = {
            height = 0.95,
            preview_width = 0.55,
            prompt_position = "bottom",
            width = 0.9,
          },
          center = {
            anchor = "N",
            width = 0.9,
            preview_cutoff = 10,
          },
          vertical = {
            height = 0.9,
            preview_height = 0.3,
            width = 0.9,
            preview_cutoff = 10,
            prompt_position = "bottom",
          },
        },

        -- Searching
        set_env = { COLORTERM = "truecolor" },
        file_ignore_patterns = {
          ".git/",
          "%.jpg",
          "%.jpeg",
          "%.png",
          "%.svg",
          "%.otf",
          "%.ttf",
          "%.lock",
          "__pycache__",
          "%.sqlite3",
          "%.ipynb",
          "vendor",
          "node_modules",
          "dotbot",
        },
        file_sorter = require("telescope.sorters").get_fuzzy_file,
      },
      pickers = {
        find_files = {
          hidden = true,
          theme = "ivy",
          prompt_prefix = " ",
          previewer = false,
          find_command = {
            "fd",
            "--type",
            "f",
            "--strip-cwd-prefix",
            "--hidden",
            "--follow",
            "--ignore-file",
            "~/.gitignore",
          },
        },
        grep_string = {
          additional_args = { "--hidden" },
        },
        live_grep = {
          prompt_prefix = " ",
          additional_args = { "--hidden" },
        },
      },
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case",
      },
      extensions = {
        persisted = {
          layout_config = { width = 0.55, height = 0.55 },
        },
      },
    }
  end,
  config = function(_, opts)
    require("telescope").setup(opts)
    pcall(require("telescope").load_extension, "fzf")
    pcall(require("telescope").load_extension, "file_browser")
    vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
    vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none" })
  end,
}
