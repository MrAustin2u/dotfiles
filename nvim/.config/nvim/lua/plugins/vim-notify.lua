return {
  "rcarriga/nvim-notify",
  config = function()
    local notify = require("notify")

    notify.setup({
      background_colour = "#000000",
      timeout = 2000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
    })

    vim.notify = notify
    require("telescope").load_extension("notify")
    require("keymaps").vim_notify_mappings(notify)
  end,
}
