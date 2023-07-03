local present, gitsigns = pcall(require, 'gitsigns')

if not present then
  return
end

local M = {}

M.setup = function()
  local opts = {
    current_line_blame = true,
    current_line_blame_opts = {
      delay = 500,
      ignore_whitespace = true,
    },
    on_attach = function(bufnr)
      require("keymaps").gitsigns_mappings(gitsigns, bufnr)
      vim.cmd("hi SignColumn guibg=None")
    end,
  }
  gitsigns.setup(opts)
end

return M
