---@diagnostic disable: redundant-parameter
local present, bufferline = pcall(require, 'bufferline')

if not present then
  return
end

local M = {}

M.setup = function()
  bufferline.setup {
    options = {
      always_show_bufferline = true,
      sort_by = 'relative_directory',
      separator_style = os.getenv 'KITTY_WINDOW_ID' and 'thin',
      diagnostics = 'nvim_lsp',
      custom_filter = function(buf)
        local ignored = { 'nnn', 'dap-repl' }
        if not vim.tbl_contains(ignored, vim.api.nvim_buf_get_option(buf, 'filetype')) then
          return true
        end
      end,
    },
  }
  require('core.mappings').bufferline_mappings()
end

return M
