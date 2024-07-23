return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  version = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make", lazy = true },
    "nvim-telescope/telescope-file-browser.nvim",
  },
  keys = require("config.keymaps").telescope_mappings(),
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
    local builtin = require "telescope.builtin"
    require("telescope").setup(opts)
    require("telescope").load_extension "fzf"
    require("telescope").load_extension "file_browser"
    vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
    vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none" })

    vim.keymap.set("n", "<leader>sc", function()
      local word = vim.fn.expand "<cWORD>"
      builtin.grep_string { search = word }
    end, { noremap = true })
  end,
}
