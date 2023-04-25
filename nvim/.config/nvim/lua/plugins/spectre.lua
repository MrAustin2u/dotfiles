local present, spectre = pcall(require, "spectre")

if not present then
  return
end

local M = {}

M.setup = function()
  spectre.setup()
  require("core.keymaps").spectre_mappings()
end

return M
