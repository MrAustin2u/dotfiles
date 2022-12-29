require("aa.options")
require("aa.keybindings")

function R(name)
  require("plenary.reload").reload_module(name)
end

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("HighlightYank", {}),
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch",
      timeout = 500,
    })
  end,
})
