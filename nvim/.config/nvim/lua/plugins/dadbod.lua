return {
  "tpope/vim-dadbod",
  cmd = "DBUI",
  dependencies = {
    "kristijanhusak/vim-dadbod-ui",
    "kristijanhusak/vim-dadbod-completion",
  },
  config = function()
    local cmp = require("cmp")

    vim.g["db_ui_winwidth"] = 60
    vim.g["db_ui_win_position"] = "left"
    vim.g["db_ui_force_echo_notifications"] = 1

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "sql", "mysql", "plsql" },
      callback = function()
        if cmp then
          cmp.setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
        end
      end,
    })

    require("keymaps").dadbod_mappings()
  end,
}
