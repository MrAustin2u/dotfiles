local M = {
  "folke/trouble.nvim",
  cmd = { "TroubleToggle", "Trouble" },
  opts = { use_diagnostic_signs = true },
}

function M.config(_, opts)
  local trouble = require("trouble")
  trouble.setup(opts)
  require("config.keymaps").trouble_mappings(trouble)
end

return M
