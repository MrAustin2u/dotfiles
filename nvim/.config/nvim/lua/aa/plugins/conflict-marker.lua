local g = vim.g

-- disable the default highlight group
g.conflict_marker_highlight_group = "Error"
-- Include text after begin and end markers
g.conflict_marker_begin = "^<<<<<<< .*$"
g.conflict_marker_end = "^>>>>>>> .*$"
