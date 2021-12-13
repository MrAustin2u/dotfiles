local nvim_lsp = require("lspconfig")
local utils = require("aa.utils")
local fn, api = vim.fn, vim.api

  local function setup_diagnostics()
  local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end

  vim.diagnostic.config({
    underline = true,
    virtual_text = false,
    signs = true, -- {severity_limit = "Warning"},
    update_in_insert = false,
    severity_sort = true,
    float = {
      show_header = true,
      source = "if_many",
      border = "single",
      focusable = false,
      severity_sort = true,
    },
  })

  --- This overwrites the diagnostic show/set_signs function to replace it with a custom function
  --- that restricts nvim's diagnostic signs to only the single most severe one per line
  local ns = api.nvim_create_namespace("severe-diagnostics")
  local show = vim.diagnostic.show
  local function display_signs(bufnr)
    -- Get all diagnostics from the current buffer
    local diagnostics = vim.diagnostic.get(bufnr)
    local filtered = utils.lsp.filter_diagnostics(diagnostics, bufnr)
    show(ns, bufnr, filtered, {
      virtual_text = false,
      underline = false,
      signs = true,
    })
  end

  function vim.diagnostic.show(namespace, bufnr, ...)
    show(namespace, bufnr, ...)
    display_signs(bufnr)
  end
end

local function root_pattern(...)
  local patterns = vim.tbl_flatten({ ... })

  return function(startpath)
    for _, pattern in ipairs(patterns) do
      return nvim_lsp.util.search_ancestors(startpath, function(path)
        if nvim_lsp.util.path.exists(fn.glob(nvim_lsp.util.path.join(path, pattern))) then
          return path
        end
      end)
    end
  end
 end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local function setup_lsp_servers()
  local function lsp_with_defaults(opts)
    opts = opts or {}
    return vim.tbl_deep_extend("keep", opts, {
      autostart = true,
      on_attach = utils.lsp.on_attach,
      capabilities = capabilities,
      flags = { debounce_text_changes = 150 },
      root_dir = vim.loop.cwd,
    })
  end

  local servers = {"tsserver", "graphql", "html", "jsonls", "cssls", "tailwindcss" }
  for _, ls in ipairs(servers) do
    nvim_lsp[ls].setup(lsp_with_defaults())
  end

  nvim_lsp.elixirls.setup(lsp_with_defaults({
    cmd = {vim.fn.expand("~/elixir-ls/release/language_server.sh")},
    root_dir = root_pattern("mix.exs", ".git") or vim.loop.os_homedir(),
    settings = {
      elixirLS = {
        dialyzerEnabled = true,
        fetchDeps = false,
        dialyzerFormat = "dialyxir_short",
        enableTestLenses = true,
        suggestSpecs = true,
      }
    },
    filetypes = { "elixir", "eelixir", "heex" },
  }))

  USER = vim.fn.expand("$USER")

  local sumneko_root_path = ""
  local sumneko_binary = ""

  sumneko_root_path = "/Users/" .. USER .. "/.config/nvim/lua-language-server"
  sumneko_binary = "/Users/" .. USER .. "/.config/nvim/lua-language-server/bin/macOS/lua-language-server"

  require"lspconfig".sumneko_lua.setup(lsp_with_defaults({
      cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"},
      settings = {
          Lua = {
              runtime = {
                  -- Tell the language server which version of Lua you"re using (most likely LuaJIT in the case of Neovim)
                  version = "LuaJIT",
                  -- Setup your lua path
                  path = vim.split(package.path, ";")
              },
              diagnostics = {
                  -- Get the language server to recognize the `vim` global
                  globals = {"vim"}
              },
              workspace = {
                  -- Make the server aware of Neovim runtime files
                  library = {[vim.fn.expand("$VIMRUNTIME/lua")] = true, [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true},
                  maxPreload = 10000
              }
          }
      }
  }))
end

setup_diagnostics()
setup_lsp_servers()
