return {
  "lewis6991/gitsigns.nvim",
  config = function()
    require("gitsigns").setup({
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 500,
        ignore_whitespace = true,
      },
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")
        require("keymaps").gitsigns_mappings(gitsigns, bufnr)
        vim.cmd("hi SignColumn guibg=None")
      end,
    })
  end,
}
