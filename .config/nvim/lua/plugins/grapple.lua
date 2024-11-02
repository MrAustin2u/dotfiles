return {
  "cbochs/grapple.nvim",
  dependencies = {
    { "nvim-tree/nvim-web-devicons", lazy = true },
  },
  cmd = "Grapple",
  keys = {
    { "<leader>m", "<cmd>Grapple toggle<cr>", desc = "Grapple toggle tag" },
    { "<leader>M", "<cmd>Grapple toggle_tags<cr>", desc = "Grapple open tags window" },
    { "<leader>n", "<cmd>Grapple cycle_tags next<cr>", desc = "Grapple cycle next tag" },
    { "<leader>p", "<cmd>Grapple cycle_tags prev<cr>", desc = "Grapple cycle previous tag" },
  },
  opts = {
    scope = "git_branch", -- can try 'git' if that's not great
    icons = true,
  },
}
