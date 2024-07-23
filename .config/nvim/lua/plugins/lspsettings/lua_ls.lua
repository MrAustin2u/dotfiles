-- Make runtime files discoverable to the lua server
local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

return {
  server_capabilities = {
    semanticTokensProvider = vim.NIL,
  },
  settings = {
    Lua = {
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
        -- Stop prompting about 'luassert'. See https://github.com/neovim/nvim-lspconfig/issues/1700
        checkThirdParty = false,
      },
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = "LuaJIT",
        -- Setup your lua path
        -- path = runtime_path,
        special = {
          spec = "require",
        },
      },
      diagnostics = {
        globals = { "vim", "spec" },
        unusedLocalExclude = { "_*" },
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}
