---@type vim.lsp.Config
return {
  cmd = { "marksman", "server" },
  filetypes = { "markdown", "markdown.mdx", "livemd" },
  root_markers = { ".marksman.toml", ".git" },
}
