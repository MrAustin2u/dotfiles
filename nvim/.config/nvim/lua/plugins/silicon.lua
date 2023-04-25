local present, silicon = pcall(require, "silicon")

if not present then
  return
end

local M = {}

M.setup = function()
  silicon.setup({
    font = 'MonoLisa',
    theme = 'tokyonight_moon',
    background = '#636da6',
    output = {
      path = "/Users/aaustin/Pictures/Screenshots",
      format = "silicon_[year][month][day]_[hour][minute][second].png",
    },
  })
end

return M
