local present, treesitter = pcall(require, "nvim-treesitter.configs")
if not present then
  return
end

treesitter.setup({
  ensure_installed = "all", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  indent = { enable = true },
  highlight = {
    enable = true, -- false will disable the whole extension
    additional_vim_regex_highlighting = false,
  },
  autotag = {
    enable = true,
  },
  matchup = { enable = true },
  rainbow = {
    enable = true,
    extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
    max_file_lines = nil, -- Do not enable for files with more than n lines, int
  },
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
})
