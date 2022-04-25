local g = vim.g

g.nvim_tree_git_hl = 1
g.nvim_tree_highlight_opened_files = 2

local ok, nvimtree = aa.safe_require("nvim-tree")
if not ok then
	return
end

nvimtree.setup({
	actions = {
		open_file = {
			quit_on_open = true,
			window_picker = {
				enable = false,
			},
		},
	},
	view = {
		width = 45,
		side = "right",
	},
	filters = {
		custom = { ".DS_Store", "*.un~" },
	},
	git = {
		enable = true,
		ignore = false,
	},
	renderer = {
		indent_markers = {
			enable = true,
		},
	},
})
