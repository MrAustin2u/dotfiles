local api, fn, loop, lsp = vim.api, vim.fn, vim.loop, vim.lsp
local diagnostic = vim.diagnostic
local tbl_deep_extend = vim.tbl_deep_extend
USER = fn.expand("$USER")
local lspinstaller = require("nvim-lsp-installer")
local inlays = require("aa.lsp.inlay")
--[[ local lspconfig_util = require("lspconfig.util") ]]

local has_lsp, lspconfig = pcall(require, "lspconfig")
if not has_lsp then
  return
end

local ts_util = require("nvim-lsp-ts-utils")

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }

for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

diagnostic.config({
  underline = true,
  virtual_text = false,
  signs = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    focusable = false,
    header = "",
    prefix = "",
    severity_sort = true,
    source = "if_many",
    style = "minimal",
  },
})

local custom_attach = require("aa.lsp.utils").on_attach
local updated_capabilities = require("aa.lsp.utils").capabilities()
local custom_init = require("aa.lsp.utils").init

--[[ setup servers ]]
local setup_server = function(server, config)
  if not config then
    return
  end

  if type(config) ~= "table" then
    config = {}
  end

  config = tbl_deep_extend("force", {
    on_init = custom_init,
    on_attach = custom_attach,
    capabilities = updated_capabilities,
    flags = {
      debounce_text_changes = nil,
    },
  }, config)

  lspconfig[server].setup(config)
end

--[[ servers ]]
local servers = {
  cssls = true,
  eslint = {
    root_dir = lspconfig.util.root_pattern(".eslintrc", ".eslintrc.js", ".eslintrc.json"),
    on_attach = function(client, bufnr)
      client.server_capabilities.documentFormattingProvider = true
      custom_attach(client, bufnr)
    end,
    capabilities = updated_capabilities,
    settings = {
      format = {
        enable = true,
      },
    },
    handlers = {
      -- this error shows up occasionally when formatting
      -- formatting actually works, so this will supress it
      ["window/showMessageRequest"] = function(_, result)
        if result.message:find("ENOENT") then
          return vim.NIL
        end

        return vim.lsp.handlers["window/showMessageRequest"](nil, result)
      end,
    },
  },
  elixirls = {
    cmd = { "/Users/aaustin/elixir-ls/release/language_server.sh" },
    settings = {
      elixirLS = {
        dialyzerEnabled = true,
      },
    },
  },
  graphql = true,
  gopls = {
    settings = {
      gopls = {
        codelenses = { test = true },
        hints = inlays and {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        } or nil,
      },
    },

    flags = {
      debounce_text_changes = 200,
    },
  },
  html = true,
  tailwindcss = true,
  jsonls = {
    json = {
      schemas = require("schemastore").json.schemas(),
    },
  },
  sumneko_lua = true,
  tsserver = {
    init_options = ts_util.init_options,
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescriptreact",
      "typescript.tsx",
    },

    on_attach = function(client)
      custom_attach(client)

      ts_util.setup({ auto_inlay_hints = false })
      ts_util.setup_client(client)
    end,
  },
}

--[[ lsp installer]]

lspinstaller.setup({
  automatic_installation = false,
  ensure_installed = { "sumneko_lua", "gopls", "elixirls", "eslint" },
})

local sumneko_cmd = {
  fn.stdpath("data") .. "/lsp_servers/sumneko_lua/extension/server/bin/lua-language-server",
}

local process = require("nvim-lsp-installer.core.process")
local path = require("nvim-lsp-installer.core.path")

local sumneko_env = {
  cmd_env = {
    PATH = process.extend_path({
      path.concat({ fn.stdpath("data"), "lsp_servers", "sumneko_lua", "extension", "server", "bin" }),
    }),
  },
}

setup_server("sumneko_lua", {
  settings = {
    Lua = {
      format = {
        enable = true,
        -- Put format options here
        -- NOTE: the value should be STRING!!
        defaultConfig = {
          indent_style = "space",
          indent_size = "2",
        },
      },
      cmd = sumneko_cmd,
      diagnostics = {
        version = "LuaJIT",
        globals = { "vim" },
      },

      workspace = {
        -- Make the server aware of Neovim runtime files
        library = api.nvim_get_runtime_file("", true),
        preloadFileSize = 500,
        maxPreload = 500,
      },
    },
  },
})

for server, config in pairs(servers) do
  setup_server(server, config)
end

--[[ set up null-ls ]]
local use_null = true
if use_null then
  local b = require("null-ls").builtins
  require("null-ls").setup({
    sources = {
      -- code actions
      b.code_actions.eslint_d,
      -- diagnostics
      b.diagnostics.credo,
      -- formatting
      b.formatting.mix,
      b.formatting.prettierd,
      b.formatting.stylua,
    },
    on_attach = custom_attach,
  })
end
