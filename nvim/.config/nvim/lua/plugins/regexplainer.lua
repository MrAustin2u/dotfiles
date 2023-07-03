local present, regexplainer = pcall(require, 'regexplainer')

if not present then
  return
end

local M = {}


M.setup = function()
  regexplainer.setup({
    auto = true,
    mappings = {
      toggle = "gR",
    },
  })
end

return M
