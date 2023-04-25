local dadbod_present, dadbod = pcall(require, "dadbod")
local cmp_present, cmp = pcall(require, "cmp")

if not dadbod_present or not cmp_present then
  return
end

local M = {}


M.setup = function()
  vim.g['db_ui_winwidth'] = 60
  vim.g['db_ui_win_position'] = 'left'
  vim.g['db_ui_force_echo_notifications'] = 1

  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'sql', 'mysql', 'plsql' },
    callback = function()
      if cmp then
        cmp.setup.buffer({ sources = { { name = 'vim-dadbod-completion' } } })
      end
    end
  })

  require("core.keymaps").dadbod_mappings()
end

return M
