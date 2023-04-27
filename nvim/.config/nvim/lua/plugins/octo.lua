return {
  "pwntester/octo.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "kyazdani42/nvim-web-devicons",
  },
  config = function()
    local octo = require("octo")

    octo.setup({
      default_remote = { "origin" },
    })

    local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
    parser_config.markdown.filetype_to_parsername = "octo"
  end,
}
