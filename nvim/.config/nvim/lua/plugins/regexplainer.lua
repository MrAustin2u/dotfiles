return {
  "bennypowers/nvim-regexplainer",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  config = function()
    local regexplainer = require("regexplainer")

    require("regexplainer").setup({
      auto = true,
      mappings = {
        toggle = "gR",
      },
    })
  end,
}
