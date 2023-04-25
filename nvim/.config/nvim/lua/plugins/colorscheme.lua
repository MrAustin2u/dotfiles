local present, tokyonight = pcall(require, "tokyonight")


if not present then
  return
end

local M  = {}

M.setup = function()
      tokyonight.setup({
        style = "moon",
        transparent = true,
        dim_inactive = true,
        hide_inactive_statusline = true,
      })
      vim.cmd([[colorscheme tokyonight-moon]])
end

return M
