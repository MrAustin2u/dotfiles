local present, ibl = pcall(require, "ibl")

if not present then
  return
end

local M = {}

M.setup = function()
  ibl.setup({
    indent = { char = "│" },
    scope = {
      show_start = false,
      show_end = false
    },
    exclude = {
      buftypes = { "NvimTree" },
      filetypes = {
        "alpha",
        "dashboard",
        "lazy",
        "lazyterm",
        "lspinfo",
        "mason",
        "notify",
        "qf",
      }
    },
  })
end

return M
