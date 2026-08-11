return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  config = true,
  cmd = {
    "ClaudeCode",
    "ClaudeCodeFocus",
    "ClaudeCodeAdd",
    "ClaudeCodeSend",
    "ClaudeCodeTreeAdd",
    "ClaudeCodeDiffAccept",
    "ClaudeCodeDiffDeny",
  },
  keys = {
    -- No bare <leader>cc entry: a lazy.nvim key stub is a real mapping and
    -- puts every <leader>cc* binding behind a timeoutlen wait. The group
    -- label is declared in whichkey.lua instead.
    { "<leader>cct",  "<cmd>ClaudeCode<cr>",            desc = "Toggle Claude" },
    { "<leader>ccf",  "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
    { "<leader>ccr",  "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
    { "<leader>ccC",  "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>ccab", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add current buffer" },
    { "<leader>ccs",  "<cmd>ClaudeCodeSend<cr>",        mode = "v",                 desc = "Send to Claude" },
    {
      "<leader>ccaf",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file",
      ft = { "oil", "snacks_picker_list" },
    },
    -- Diff management
    { "<leader>ccad", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ccdd", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Deny diff" },
  },
  opts = {
    terminal = {
      ---@module "snacks"
      ---@type snacks.win.Config|{}
      snacks_win_opts = {
        position = "bottom",
        height = 0.4,
      },
    },
  },
}
