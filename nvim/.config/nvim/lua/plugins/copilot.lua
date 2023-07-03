local present, copilot = pcall(require, 'copilot')

if not present then
  return
end

local M = {}

M.setup = function()
  copilot.setup({
    suggestion = { enabled = false },
    panel = { enabled = false },
  })
end

return M
