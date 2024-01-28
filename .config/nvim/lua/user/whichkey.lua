local M = {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300
	end,
	opts = {
		defaults = {
			["<leader>t"] = { name = "+test" },
		},
		plugins = { spelling = true },
	},
}

function M.config(_, opts)
	local whichkey = require("which-key")
	whichkey.setup(opts)

	local keymaps = {
		mode = { "n", "v" },
		["g"] = { name = "+goto" },
		["gz"] = { name = "+surround" },
		["]"] = { name = "+next" },
		["["] = { name = "+prev" },
		["<leader><tab>"] = { name = "+tabs" },
		["<leader>b"] = { name = "+buffer" },
		["<leader>c"] = { name = "+code" },
		["<leader>f"] = { name = "+file/find" },
		["<leader>g"] = { name = "+git" },
		["<leader>gh"] = { name = "+hunks" },
		["<leader>q"] = { name = "+quit/session" },
		["<leader>s"] = { name = "+search" },
		["<leader>u"] = { name = "+ui" },
		["<leader>w"] = { name = "+windows" },
		["<leader>x"] = { name = "+diagnostics/quickfix" },
	}
	keymaps["<leader>sn"] = { name = "+noice" }

	whichkey.register(keymaps)
end

return M
