local api, cmd, lsp, o = vim.api, vim.cmd, vim.lsp, vim.o
local tbl_filter, deepcopy = vim.tbl_filter, vim.deepcopy

local M = {}

M.run = function()
  if o.modified then
    cmd([[w]])
  end

  local bufnr = api.nvim_get_current_buf()
  local line = api.nvim_win_get_cursor(0)[1]

  local lenses = deepcopy(lsp.codelens.get(bufnr))

  lenses = tbl_filter(function(v)
    return v.range.start.line < line
  end, lenses)

  if lenses ~= nil then
    table.sort(lenses, function(a, b)
      return a.range.start.line < b.range.start.line
    end)

    local _, lens = next(lenses)

    local client_id = next(lsp.buf_get_active_clients(bufnr))
    local client = lsp.get_client_by_id(client_id)
    client.request("workspace/executeCommand", lens.command, function(...)
      local result = lsp.handlers["workspace/executeCommand"](...)
      lsp.codelens.refresh()
      return result
    end, bufnr)
  end
end

return M
