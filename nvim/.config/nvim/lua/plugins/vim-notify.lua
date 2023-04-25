local present, notify = pcall(require, "notify")

if not present then
  return
end

local M = {}

M.setup = function()
  notify.setup({
    background_colour = "#000000",
    timeout = 3000,
    max_height = function()
      return math.floor(vim.o.lines * 0.75)
    end,
    max_width = function()
      return math.floor(vim.o.columns * 0.75)
    end,
  })

  vim.notify = notify
  require('telescope').load_extension('notify')
  require("core.keymaps").vim_notify_mappings(notify)
end

return M
