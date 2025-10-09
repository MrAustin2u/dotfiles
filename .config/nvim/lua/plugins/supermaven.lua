return {
  "supermaven-inc/supermaven-nvim",
  opts = {
    log_level = "off",
    disable_inline_completion = true, -- disables inline completion for use with cmp
    disable_keymaps = true, -- disables built in keymaps for more manual control
    disable_native_completion = true, -- disable built-in completion
  },
  config = function(_, opts)
    require("supermaven-nvim").setup(opts)
  end,
}
