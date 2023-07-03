local present, spectre = pcall(require, 'spectre')

if not present then
  return
end

local M = {}

M.setup = function()
  spectre.setup()
  require("keymaps").spectre_mappings(spectre)
end

return M
