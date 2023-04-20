return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  version = false, -- telescope did only one release, so use HEAD for now
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-telescope/telescope-file-browser.nvim",
    "nvim-telescope/telescope-github.nvim",
  },
  config = function()
    local telescope = require("telescope")

    telescope.setup({
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
    })

    local extensions = {
      "attempt",
      "file_browser",
      "fzf",
      "gh",
    }

    for _, e in ipairs(extensions) do
      telescope.load_extension(e)
    end

    require("core.keymaps").telescope_mappings()
  end,
}
