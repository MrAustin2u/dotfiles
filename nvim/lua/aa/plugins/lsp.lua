local nvim_lsp = require("lspconfig")
local utils = require("aa.utils")
local fn, api, vcmd, lsp = vim.fn, vim.api, vim.cmd, vim.lsp
local nnoremap, noremap, au = aa.nnoremap, aa.nmap, aa.au

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

local on_attach = function(client, bufnr)
  local opts = {bufnr = bufnr}
  require("lsp-status").on_attach(client)
  utils.lsp.format_setup(client, bufnr)

  nnoremap("K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  nnoremap("gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  nnoremap("<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
  nnoremap("<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
  nnoremap("<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
  nnoremap("<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
  nnoremap("<space>nr", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  nnoremap("<space>e", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)
  nnoremap("<leader>,", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
  nnoremap("<leader>.", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
  noremap("<space>f", "<cmd>lua vim.lsp.buf.formatting_sync()<CR>", opts)

  --- # autocommands/autocmds
  au([[CursorHold,CursorHoldI <buffer> lua require('aa.utils').lsp.line_diagnostics()]])
  au([[CursorMoved,BufLeave <buffer> lua vim.lsp.buf.clear_references()]])
  vcmd([[command! FormatDisable lua require('aa.utils').lsp.formatToggle(true)]])
  vcmd([[command! FormatEnable lua require('aa.utils').lsp.formatToggle(false)]])

  if client.resolved_capabilities.code_lens then
    au("CursorHold,CursorHoldI,InsertLeave <buffer> lua vim.lsp.codelens.refresh()")
  end

   --- # commands
  FormatRange = function()
    local start_pos = api.nvim_buf_get_mark(0, "<")
    local end_pos = api.nvim_buf_get_mark(0, ">")
    lsp.buf.range_formatting({}, start_pos, end_pos)
  end
  vcmd([[ command! -range FormatRange execute 'lua FormatRange()' ]])
  vcmd([[ command! Format execute 'lua vim.lsp.buf.formatting_sync(nil, 1000)' ]])
  vcmd([[ command! LspLog lua vim.cmd('vnew'..vim.lsp.get_log_path()) ]])

  local disabled_formatting_ls = { "jsonls", "tailwindcss", "html" }
  for i = 1, #disabled_formatting_ls do
    if disabled_formatting_ls[i] == client.name then
      client.resolved_capabilities.document_formatting = false
      client.resolved_capabilities.document_range_formatting = false
    end
  end

  api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
end

local function setup_lsp_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.codeLens = { dynamicRegistration = false }
  capabilities.textDocument.completion.completionItem.documentationFormat = { "markdown" }
  capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
end

local function setup_lsp_servers()
  local function lsp_with_defaults(opts)
    opts = opts or {}
    return vim.tbl_deep_extend("keep", opts, {
      autostart = true,
      on_attach = on_attach,
      capabilities = setup_lsp_capabilities(),
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
        dialyzerEnabled = false,
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

  require"aa.plugins.null-ls".setup()
  nvim_lsp["null-ls"].setup(lsp_with_defaults())
end

setup_diagnostics()
setup_lsp_servers()
