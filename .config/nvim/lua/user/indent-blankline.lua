local M = {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	event = { "BufReadPost", "BufNewFile" },
}

function M.config()
	local ibl = require("ibl")

	ibl.setup({
		indent = { char = "│", tab_char = "│" },
		scope = {
			show_start = false,
			show_end = false,
			enabled = false,
		},
		exclude = {
			buftypes = { "NvimTree", "TelescopePrompt" },
			filetypes = {
				"alpha",
				"dashboard",
				"lazy",
				"lazyterm",
				"lspinfo",
				"man",
				"mason",
				"neo-tree",
				"notify",
				"qf",
			},
		},
	})
end

return M
