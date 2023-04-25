local present, copilot = pcall(require, "copilot")

if not present then
  return
end

local M = {}

local opts = {
  -- cmp = { enabled = true, method = "getCompletionCycling" },
  -- ft_disable = { "markdown" },
  panel = { enabled = false },
  -- server_opts_overrides = {
  --   -- trace = "verbose",
  --   settings = {
  --     advanced = {
  --       -- listCount = 10, -- #completions for panel
  --       inlineSuggestCount = 3, -- #completions for getCompletions
  --     },
  --   },
  -- },
  suggestion = { enabled = false },
}

M.setup = function()
  copilot.setup(opts)
end

return M
