local present, indent_blankline = pcall(require, 'indent_blankline')

if not present then
  return
end

local default = {
  char = "┊", -- char_list = { "│", "|", "¦", "┆", "┊" }
  space_char_blankline = " ",
  buftype_exclude = { "terminal", "nofile" },
  filetype_exclude = {
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
  },
  use_treesitter = true,
  show_trailing_blankline_indent = false,
  show_end_of_line = true,
  show_current_context = true,
  show_first_indent_level = true,
  context_patterns = {
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
  },
}

local M = {}

M.setup = function()
  ---@diagnostic disable-next-line: redundant-parameter
  indent_blankline.setup(default)
end

return M
