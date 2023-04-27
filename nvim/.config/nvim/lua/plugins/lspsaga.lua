return {
  "glepnir/lspsaga.nvim",
  branch = "main",
  config = function()
    local lspsaga = require("lspsaga")

    lspsaga.setup({
      code_action_lightbulb = {
        enable = true,
        sign = true,
        enable_in_insert = true,
        sign_priority = 20,
        virtual_text = false,
      },
      symbol_in_winbar = {
        enable = false,
      },
    })

    require("keymaps").lsp_saga_mappings()
  end,
}
