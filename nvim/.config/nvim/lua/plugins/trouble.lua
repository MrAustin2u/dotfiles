return {
  "folke/trouble.nvim",
  config = function()
    local trouble = require("trouble")

    trouble.setup()
    require("keymaps").trouble_mappings()
  end,
}
