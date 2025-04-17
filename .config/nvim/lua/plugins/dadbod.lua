---@type LazySpec[]
return {
  "tpope/vim-dadbod",
  cmd = { "DB" },
  dependencies = {
    "kristijanhusak/vim-dadbod-ui",
  },
  keys = {
    { "<leader>do", ":DBUI<CR><CR>",  desc = "Database UI Open" },
    { "<leader>dc", ":DBUIClose<CR>", desc = "Database UI Close" },
  },
  config = function()
    -- Your DBUI configuration
    vim.g.db_ui_use_nerd_fonts = true
    vim.g.db_ui_execute_on_save = false
    vim.g.db_ui_disable_mappings = true
    vim.g.db_ui_save_location = "$HOME/code/sql/queries"
    vim.g.db_ui_use_nvim_notify = true
  end,
}
