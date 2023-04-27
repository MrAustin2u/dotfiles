return {
  "vim-test/vim-test",
  dependencies = {
    "preservim/vimux",
  },
  config = function()
    vim.g["test#strategy"] = "vimux"
    vim.g["test#preserve_screen"] = 0

    require("keymaps").vim_test_mappings()
  end,
}
