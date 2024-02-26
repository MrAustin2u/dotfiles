return {
  keys = {
    {
      "<leader>co",
      function()
        vim.lsp.buf.code_action({
          apply = true,
          context = {
            only = { "source.organizeImports.ts" },
            diagnostics = {},
          },
        })
      end,
      desc = "Organize Imports",
    },
  },
  settings = {
    completions = {
      completeFunctionCalls = true,
    },
  },
}
