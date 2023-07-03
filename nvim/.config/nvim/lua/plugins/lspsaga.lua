local present, lspsaga = pcall(require, "lspsaga")

if not present then
  return
end

local M = {}

M.setup = function()
  lspsaga.setup({
    lightbulb = {
      enable = true,
      sign = true,
      enable_in_insert = true,
      sign_priority = 40,
      virtual_text = false,
    },
    symbol_in_winbar = {
      enable = false,
    },
  })

  require("keymaps").lsp_saga_mappings()
end

return M
