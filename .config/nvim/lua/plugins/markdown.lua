return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "echasnovski/mini.icons",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    file_types = { "markdown", "norg", "rmd", "org", "livemd" },
    code = {
      sign = false,
      width = "block",
      right_pad = 1,
    },
    heading = {
      sign = false,
      icons = {},
    },
  },
  ft = { "markdown", "norg", "rmd", "org" },
  enabled = true,
}
