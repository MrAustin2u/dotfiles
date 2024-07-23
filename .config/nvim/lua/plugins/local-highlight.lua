return {
  "tzachar/local-highlight.nvim",
  config = function()
    vim.cmd [[hi TSDefinitionUsage guibg=#565f89]]

    require("local-highlight").setup()
  end,
}
