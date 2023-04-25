local present, octo = pcall(require, "octo")

if not present then
  return
end

local M = {}

M.setup = function()
  octo.setup({
    default_remote = { 'origin' },
  })

  local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
  parser_config.markdown.filetype_to_parsername = 'octo'
end


return M
