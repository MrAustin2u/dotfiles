return {
  server_capabilities = {
    semanticTokensProvider = vim.NIL,
  },
  settings = {
    Lua = {
      workspace = {
        checkThirdParty = "Disable",
        library = {
          [vim.fn.expand "$VIMRUNTIME/lua"] = true,
          [vim.fn.stdpath "config" .. "/lua"] = true,
        },
      },
      runtime = {
        version = "LuaJIT",
        special = {
          spec = "require",
        },
      },
      diagnostics = {
        globals = { "vim", "spec" },
        unusedLocalExclude = { "_*" },
      },
    },
  },
}
