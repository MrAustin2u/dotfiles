local cmd, lsp = vim.cmd, vim.lsp
local inlay_hints = require("lsp_extensions.inlay_hints")

local M = {}

M.show_line_hints = function()
  lsp.buf_request(
    0,
    "rust-analyzer/inlayHints",
    inlay_hints.get_params(),
    inlay_hints.get_callback({
      only_current_line = true,
    })
  )
end

-- @rockerboo
M.show_line_hints_on_cursor_events = function()
  cmd([[augroup ShowLineHints]])
  cmd([[  au!]])
  cmd([[  autocmd CursorHold,CursorHoldI,CursorMoved *.rs :lua require('aa.lsp_extensions').show_line_hints()]])
  cmd([[augroup END]])
end

return M
