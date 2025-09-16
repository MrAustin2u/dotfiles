---@type vim.lsp.Config
return {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = {
    "package.json",
    "tsconfig.json", 
    "jsconfig.json",
    "node_modules",
    ".git",
  },
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
      includeCompletionsForModuleExports = true,
      quotePreference = "auto",
    },
  },
  on_attach = function(client, bufnr)
    -- prevent conflict with Deno (ts_ls was showing false positives)
    if require("config.utils").root_pattern("deno.json", "deno.jsonc")(vim.fn.getcwd()) then
      vim.lsp.stop_client(client.id)
      vim.lsp.buf_detach_client(bufnr, client.id)
    end
  end,
}
