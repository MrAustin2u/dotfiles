return {
  "rcarriga/nvim-notify",
  dependencies = {
    "stevearc/dressing.nvim",
  },
  opts = {
    stages = "static",
    background_colour = "#000000",
    timeout = 3000,
    max_height = function()
      return math.floor(vim.o.lines * 0.75)
    end,
    max_width = function()
      return math.floor(vim.o.columns * 0.75)
    end,
    on_open = function(win)
      vim.api.nvim_win_set_config(win, { zindex = 100 })
    end,
  },
  keys = {
    {
      "<leader>un",
      function()
        require("notify").dismiss { silent = true, pending = true }
      end,
      desc = "Dismiss all Notifications",
    },
  },
  init = function()
    -- when noice is not enabled, install notify on VeryLazy
    if not require("config.utils").has "noice.nvim" then
      require("config.utils").on_very_lazy(function()
        vim.notify = require "notify"
      end)
    end
  end,
  config = function(_, opts)
    local notify = require "notify"
    notify.setup(opts)
    vim.notify = notify
    require("telescope").load_extension "notify"
  end,
}
