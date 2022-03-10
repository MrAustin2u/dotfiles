local g = vim.g

g.nvim_tree_indent_markers = 1
g.nvim_tree_git_hl = 1
g.nvim_tree_highlight_opened_files = 1

require("nvim-tree").setup({
	view = {
		width = 45,
		side = "right",
	},
	filters = {
		dotfiles = false,
		custom = { ".DS_Store", "*.un~" },
	},
	git = {
		enable = true,
		ignore = false,
		timeout = 500,
	},
})
