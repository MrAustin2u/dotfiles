local present, noice = pcall(require, "noice")

if not present then
  return
end

local M = {}

M.setup = function()
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

  require("core.keymaps").noice_mappings(noice)
end

return M
