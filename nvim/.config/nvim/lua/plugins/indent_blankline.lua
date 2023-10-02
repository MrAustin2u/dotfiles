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
      show_end = false,
      enabled = false,
    },
    exclude = {
      buftypes = { "NvimTree", 'TelescopePrompt' },
      filetypes = {
        "alpha",
        "dashboard",
        "lazy",
        "lazyterm",
        "lspinfo",
        "man",
        "mason",
        "notify",
        "qf",
      }
    },
  })
end

return M
