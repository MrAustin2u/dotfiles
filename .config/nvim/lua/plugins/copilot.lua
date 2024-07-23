return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  dependencies = {
    {
      "zbirenbaum/copilot-cmp",
      config = true,
    },
  },
  opts = {
    filetypes = { ["*"] = true },
    suggestion = { enabled = false },
    panel = { enabled = false },
  },
}
