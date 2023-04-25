local present, treesitter = pcall(require, "nvim-treesitter.configs")

if not present then
  return
end

local M = {}

local opts = {
  highlight = { enable = true },
  indent = { enable = true },
  context_commentstring = { enable = true, enable_autocmd = false },
  ensure_installed = {
    "bash",
    "css",
    "dockerfile",
    "eex",
    "elixir",
    "erlang",
    "git_rebase",
    "gitcommit",
    "gitignore",
    "go",
    "graphql",
    "heex",
    "html",
    "javascript",
    "json",
    "json5",
    "jsonc",
    "lua",
    "markdown",
    "markdown_inline",
    "python",
    "regex",
    "rust",
    "scss",
    "sql",
    "typescript",
    "vim",
    "yaml",
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<C-space>",
      node_incremental = "<C-space>",
      scope_incremental = "<nop>",
      node_decremental = "<bs>",
    },
  },
}

M.setup = function()
  vim.cmd([[
      set foldmethod=expr
      set foldexpr=nvim_treesitter#foldexpr()
      " disable folds at startup
      set nofoldenable
      ]])

  treesitter.setup(opts)
end

return M
