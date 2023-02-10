return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  version = false, -- telescope did only one release, so use HEAD for now
  keys = {
    { "<leader>,", "<cmd>Telescope buffers show_all_buffers=true<cr>", desc = "Switch Buffer", remap = false },
    { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History", remap = false },
    -- find
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers", remap = false },
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
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent", remap = false },
    -- git
    { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "commits", remap = false },
    { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "status", remap = false },
    -- search
    { "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Auto Commands", remap = false },
    { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer", remap = false },
    { "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Command History", remap = false },
    { "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands", remap = false },
    { "<leader>sd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics", remap = false },
    { "<leader>sg", "<cmd>Telescope live_grep<cr>", desc = "Grep(cwd)", remap = false },
    { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages", remap = false },
    { "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups", remap = false },
    { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps", remap = false },
    { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages", remap = false },
    { "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark", remap = false },
    { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options", remap = false },
    { "<leader>sw", "<cmd>Telescope grep_string<cr>", desc = "Word", remap = false },
    {
      "<leader>uC",
      "<cmd>lua require('telescope.builtin').colorscheme({ enable_preview = true })<cr>",
      desc = "Colorscheme with preview",
    },
  },
  opts = {
    defaults = {
      prompt_prefix = " ",
      selection_caret = " ",
      mappings = {
        i = {
          ["<C-t>"] = function(...)
            return require("trouble.providers.telescope").open_with_trouble(...)
          end,
          ["<A-i>"] = function()
            require("telescope.builtin").find_files({ no_ignore = true })()
          end,
          ["<A-h>"] = function()
            require("telescope.builtin").find_files({ hidden = true })()
          end,
          ["<C-Down>"] = function(...)
            return require("telescope.actions").cycle_history_next(...)
          end,
          ["<C-Up>"] = function(...)
            return require("telescope.actions").cycle_history_prev(...)
          end,
        },
      },
    },
  },
}
