return {
  "folke/trouble.nvim",
  cmd = { "TroubleToggle", "Trouble" },
  opts = { use_diagnostic_signs = true },
  config = function(_, opts)
    local trouble = require "trouble"
    trouble.setup(opts)
    require("config.keymaps").trouble_mappings(trouble)
  end,
}
