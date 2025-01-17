return {
  "mhanberg/output-panel.nvim",
  version = "*",
  event = "VeryLazy",
  config = true,
  cmd = { "OutputPanel" },
  keys = {
    {
      "<leader>o",
      vim.cmd.OutputPanel,
      mode = "n",
      desc = "Toggle the output panel",
    },
  },
}
