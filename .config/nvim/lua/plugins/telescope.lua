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
  end,
  config = function(_, opts)
    require("telescope").setup(opts)
    pcall(require("telescope").load_extension, "fzf")
    pcall(require("telescope").load_extension, "file_browser")
    vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
    vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none" })
  end,
}
