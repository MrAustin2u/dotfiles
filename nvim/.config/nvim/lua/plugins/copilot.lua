return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup({
        cmp = { enabled = true, method = "getCompletionCycling" },
        ft_disable = { "markdown" },
        panel = { enabled = false },
        server_opts_overrides = {
          -- trace = "verbose",
          settings = {
            advanced = {
              -- listCount = 10, -- #completions for panel
              inlineSuggestCount = 3, -- #completions for getCompletions
            },
          },
        },
        suggestion = { enabled = false },
      })
    end,
  },
  {
    'zbirenbaum/copilot-cmp',
    dependencies = { 'zbirenbaum/copilot.lua' },
    config = true
  }
}
