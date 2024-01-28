local M = {
	"rcarriga/nvim-notify",
	dependencies = {
		"stevearc/dressing.nvim",
	},
	keys = {
		{
			"<leader>un",
			function()
				require("notify").dismiss({ silent = true, pending = true })
			end,
			desc = "Dismiss all Notifications",
		},
	},
}
function M.config()
	local notify = require("notify")
	notify.setup({
		background_colour = "#000000",
	})
	vim.notify = notify
	require("telescope").load_extension("notify")
end

return M
