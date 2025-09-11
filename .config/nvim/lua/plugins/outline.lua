local kind_filter = require("config.utils").kind_filter
local icons = require("config.utils").icons

return {
  "hedyhli/outline.nvim",
  keys = { { "<leader>cs", "<cmd>Outline<cr>", desc = "Toggle Outline" } },
  cmd = "Outline",
  opts = function()
    local defaults = require("outline.config").defaults
    local opts = {
      symbols = {
        icons = {},
        filter = vim.deepcopy(kind_filter),
      },
      keymaps = {
        up_and_jump = "<up>",
        down_and_jump = "<down>",
      },
    }

    for kind, symbol in pairs(defaults.symbols.icons) do
      opts.symbols.icons[kind] = {
        icon = icons.kinds[kind] or symbol.icon,
        hl = symbol.hl,
      }
    end
    return opts
  end,
}
