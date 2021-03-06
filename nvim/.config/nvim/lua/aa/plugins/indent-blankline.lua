local g = vim.g

g.indent_blankline_char = "│" -- char_list = { "│", "|", "¦", "┆", "┊" },
g.indent_blankline_space_char_blankline = " "
g.indent_blankline_buftype_exclude = { "terminal", "nofile" }
g.indent_blankline_filetype_exclude = {
	"help",
	"startify",
	"dashboard",
	"alpha",
	"packer",
	"neogitstatus",
	"NvimTree",
	"Trouble",
	"git",
	"org",
	"orgagenda",
	"NvimTree",
	"fzf",
	"log",
	"fugitive",
	"gitcommit",
	"packer",
	"vimwiki",
	"markdown",
	"json",
	"txt",
}
g.indent_blankline_use_treesitter = true
g.indent_blankline_show_trailing_blankline_indent = false
g.indent_blankline_show_end_of_line = true
g.indent_blankline_show_current_context = true
g.indent_blankline_show_first_indent_level = true
g.indent_blankline_show_end_of_line = true
g.indent_blankline_context_patterns = {
	"class",
	"return",
	"function",
	"method",
	"^if",
	"^while",
	"jsx_element",
	"^for",
	"^object",
	"^table",
	"block",
	"arguments",
	"if_statement",
	"else_clause",
	"jsx_element",
	"jsx_self_closing_element",
	"try_statement",
	"catch_clause",
	"import_statement",
	"operation_type",
}
