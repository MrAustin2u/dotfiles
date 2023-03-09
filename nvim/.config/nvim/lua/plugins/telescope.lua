return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  version = false, -- telescope did only one release, so use HEAD for now
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-telescope/telescope-file-browser.nvim",
  },
  config = function()
    require("telescope").setup({
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

    require("telescope").load_extension("attempt")
    require("telescope").load_extension("fzf")
    require("telescope").load_extension("file_browser")
  end,
  keys = {
    { "<leader>:",  "<cmd>Telescope command_history<cr>", desc = "Command History", remap = false },
    -- find
    { "<leader>fb", "<cmd>Telescope buffers<cr>",         desc = "Buffers",         remap = false },
    {
      "<leader>ff",
      "<cmd>lua require('telescope.builtin').find_files({hidden = true})<cr>",
      desc = "Find Files",
      remap = false,
    },
    {
      "<leader>fg",
      "<cmd>lua require('telescope.builtin').git_files({hidden = true})<cr>",
      desc = "Find Files (git)",
      remap = false,
    },
    -- search
    { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer",          remap = false },
    { "<leader>sc", "<cmd>Telescope command_history<cr>",           desc = "Command History", remap = false },
    { "<leader>sC", "<cmd>Telescope commands<cr>",                  desc = "Commands",        remap = false },
    { "<leader>sd", "<cmd>Telescope diagnostics<cr>",               desc = "Diagnostics",     remap = false },
    { "<leader>sg", "<cmd>Telescope live_grep<cr>",                 desc = "Grep(cwd)",       remap = false },
    { "<leader>sh", "<cmd>Telescope help_tags<cr>",                 desc = "Help Pages",      remap = false },
    { "<leader>sk", "<cmd>Telescope keymaps<cr>",                   desc = "Key Maps",        remap = false },
    { "<leader>sw", "<cmd>Telescope grep_string<cr>",               desc = "Word",            remap = false },
    {
      "<leader>uC",
      "<cmd>lua require('telescope.builtin').colorscheme({ enable_preview = true })<cr>",
      desc = "Colorscheme with preview",
    },
  },
}
