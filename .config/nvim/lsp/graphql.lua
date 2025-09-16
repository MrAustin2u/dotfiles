---@type vim.lsp.Config
return {
  cmd = { "graphql-lsp", "server", "-m", "stream" },
  filetypes = { "graphql", "typescriptreact", "javascriptreact", "javascript" },
  root_markers = { ".graphqlrc*", ".graphql.config.*", "graphql.config.*" },
}
