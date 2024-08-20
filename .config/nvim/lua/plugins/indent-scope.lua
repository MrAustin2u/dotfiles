return {
  "echasnovski/mini.indentscope",
  version = false,
  opts = {
    symbol = "│",
    options = { try_as_border = true },
    draw = {
      -- disable animation, remove to re-enable
      animation = function()
        return 0
      end,
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "help",
        "alpha",
        "dashboard",
        "neo-tree",
        "Trouble",
        "lazy",
        "mason",
        "notify",
        "toggleterm",
        "lazyterm",
      },
      callback = function()
        vim.b.miniindentscope_disable = true
      end,
    })
  end,
}
