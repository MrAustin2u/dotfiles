return {
  "windwp/nvim-spectre",
  config = function()
    local spectre = require("spectre")
    spectre.setup()
    require("keymaps").spectre_mappings()
  end,
}
