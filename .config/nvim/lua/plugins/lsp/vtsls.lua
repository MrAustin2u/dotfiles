return {
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  settings = {
    complete_function_calls = true,
    vtsls = {
      enableMoveToFileCodeAction = true,
      autoUseWorkspaceTsdk = true,
      experimental = {
        maxInlayHintLength = 30,
        completion = {
          enableServerSideFuzzyMatch = true,
        },
      },
    },
    typescript = {
      updateImportsOnFileMove = { enabled = "always" },
      suggest = {
        completeFunctionCalls = true,
      },
      inlayHints = {
        enumMemberValues = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        parameterNames = { enabled = "literals" },
        parameterTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        variableTypes = { enabled = false },
      },
    },
  },
  keys = {
    {
      "gD",
      function()
        local params = vim.lsp.util.make_position_params()
        aa.lsp.execute {
          command = "typescript.goToSourceDefinition",
          arguments = { params.textDocument.uri, params.position },
          open = true,
        }
      end,
      desc = "Goto Source Definition",
    },
    {
      "gR",
      function()
        aa.lsp.execute {
          command = "typescript.findAllFileReferences",
          arguments = { vim.uri_from_bufnr(0) },
          open = true,
        }
      end,
      desc = "File References",
    },
    {
      "<leader>co",
      aa.lsp.action["source.organizeImports"],
      desc = "Organize Imports",
    },
    {
      "<leader>cM",
      aa.lsp.action["source.addMissingImports.ts"],
      desc = "Add missing imports",
    },
    {
      "<leader>cu",
      aa.lsp.action["source.removeUnused.ts"],
      desc = "Remove unused imports",
    },
    {
      "<leader>cD",
      aa.lsp.action["source.fixAll.ts"],
      desc = "Fix all diagnostics",
    },
    {
      "<leader>cV",
      function()
        aa.lsp.execute { command = "typescript.selectTypeScriptVersion" }
      end,
      desc = "Select TS workspace version",
    },
  },
}
