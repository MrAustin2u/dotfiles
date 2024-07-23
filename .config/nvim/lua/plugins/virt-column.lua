return {
  "lukas-reineke/virt-column.nvim",
  config = function(_, opts)
    require("virt-column").setup(opts)
    vim.cmd [[ au VimEnter * highlight VirtColumn guifg=#1e2030 gui=nocombine ]]
  end,
}
