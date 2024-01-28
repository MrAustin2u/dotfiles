local M = {
	"lukas-reineke/virt-column.nvim",
}

function M.config(_, opts)
	require("virt-column").setup(opts)
	vim.cmd([[ au VimEnter * highlight VirtColumn guifg=#1e2030 gui=nocombine ]])
end

return M
