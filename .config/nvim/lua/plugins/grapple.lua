return {
  "cbochs/grapple.nvim",
  dependencies = {
    { "nvim-tree/nvim-web-devicons", lazy = true },
  },
  cmd = "Grapple",
  keys = {
    -- Kept under a <leader>j prefix: bare single letters shadow every
    -- <leader>{m,n,p}* submapping behind a timeoutlen wait.
    { "<leader>jj", "<cmd>Grapple toggle<cr>",          desc = "Grapple toggle tag" },
    { "<leader>jl", "<cmd>Grapple toggle_tags<cr>",     desc = "Grapple open tags window" },
    { "<leader>jn", "<cmd>Grapple cycle_tags next<cr>", desc = "Grapple cycle next tag" },
    { "<leader>jp", "<cmd>Grapple cycle_tags prev<cr>", desc = "Grapple cycle previous tag" },
  },
  opts = {
    scope = "git_branch", -- can try 'git' if that's not great
    icons = true,
  },
}
