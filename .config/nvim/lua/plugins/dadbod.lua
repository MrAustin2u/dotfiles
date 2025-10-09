---@type LazySpec[]
return {
  "kristijanhusak/vim-dadbod-ui",
  cmd = {
    "DBUI",
    "DBUIToggle",
    "DBUIAddConnection",
    "DBUIFindBuffer",
  },
  dependencies = {
    {
      "tpope/vim-dadbod",
      lazy = true,
      keys = {
        { "<leader>do",  ":DBUI<CR><CR>",          desc = "Database UI Open" },
        { "<leader>dc",  ":DBUIClose<CR>",         desc = "Database UI Close" },
        { "<leader>dba", ":DBUIAddConnection<CR>", desc = "Database add connection" },
      },
    },
    {
      "kristijanhusak/vim-dadbod-completion",
      ft = { "sql", "mysql", "plsql" },
      lazy = true,
      init = function()
        vim.g.vim_dadbod_completion_lowercase_keywords = true
      end,
    }, -- Optional
  },
  init = function()
    -- Your DBUI configuration
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_execute_on_save = 0
    vim.g.db_ui_disable_mappings = 1
    vim.g.db_ui_save_location = vim.fn.expand("~/.local/share/nvim/db_ui")
    vim.g.db_ui_use_nvim_notify = 1
  end,
}
