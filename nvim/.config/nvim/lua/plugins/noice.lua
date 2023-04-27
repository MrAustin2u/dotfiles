return {
  "folke/noice.nvim",
  event = "VeryLazy",
  config = function()
    local noice = require("noice")

    noice.setup({
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
    })

    require("keymaps").noice_mappings(noice)
  end,
}
