local cmp_present, cmp = pcall(require, "cmp")
local dadbod_completion_present, _ = pcall(require, "vim-dadbod-completion")
local dadbod_present, dadboad = pcall(require, "vim-dadbod")
local dadbod_ui_present, _ = pcall(require, "vim-dadbod-ui")

if not cmp_present and dadbod_present and dadbod_ui_present and dadbod_completion_present then
  return
end

local M = {}

M.setup = function()
  vim.opt.cmdheight = 1
  vim.g.db_ui_show_help = 0
  vim.g.db_ui_win_position = "left"
  vim.g.db_ui_tmp_query_location = "~/Developer/queries"

  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "sql", "mysql", "plsql" },
    callback = function()
      cmp.setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
    end,
  })
end

return M
