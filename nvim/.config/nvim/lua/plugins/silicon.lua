local present, silicon = pcall(require, "silicon")

if not present then
  return
end

local M = {}

M.setup = function()
  silicon.setup({
    font = "MonoLisa",
    theme = "tokyonight_moon",
    bgColor = "#636da6",
  })
  require("keymaps").silicon_mappings()
end

return M
