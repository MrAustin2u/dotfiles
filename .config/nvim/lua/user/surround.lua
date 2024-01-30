local M = {
  "kylechui/nvim-surround",
  version = "*",
  event = "VeryLazy",
}

function M.config(_, opts)
  require("nvim-surround").setup(opts)
end

return M
