---@type LazySpec[]
return {
  "kristijanhusak/vim-dadbod-ui",
  dependencies = {
    {
      "tpope/vim-dadbod",
      lazy = true,
      keys = {
        { "<leader>do", ":DBUI<CR><CR>",  desc = "Database UI Open" },
        { "<leader>dc", ":DBUIClose<CR>", desc = "Database UI Close" },
      },
    },
    { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true }, -- Optional
  },
  cmd = {
    "DBUI",
    "DBUIToggle",
    "DBUIAddConnection",
    "DBUIFindBuffer",
  },
  init = function()
    -- Your DBUI configuration
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_execute_on_save = 0
    vim.g.db_ui_disable_mappings = 1
    vim.g.db_ui_save_location = "$HOME/code/sql/queries"
    vim.g.db_ui_use_nvim_notify = 1
  end,
}
