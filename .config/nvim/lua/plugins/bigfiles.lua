return {
  "LunarVim/bigfile.nvim",
  lazy = false,
  config = function()
    require("bigfile").setup {
      filesize = 2, -- 1MB threshold (adjust as needed)
      pattern = { "*" },
      features = {
        "indent_blankline",
        "illuminate",
        "lsp",
        "treesitter",
        "syntax",
        "vimoptions",
      },
    }
  end,
}
