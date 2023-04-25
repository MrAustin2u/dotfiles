local utils = require("core.utils")

local lspconfig_present, lspconfig = pcall(require, "lspconfig")
local cmp_lsp_present, cmp_lsp = pcall(require, "cmp_nvim_lsp")
local navic_present, navic = pcall(require, "nvim-navic")
local elixir_present, elixir = pcall(require, "elixir")

local deps = {
  cmp_lsp_present,
  lspconfig_present,
  navic_present,
  elixir_present,
}

if utils.contains(deps, false) then
  vim.notify("Failed to load dependencies in plugins/lsp.lua")
  return
end

local M = {}

local on_attach = function(client, bufnr)
  -- dont format if client disabled it
  if
    client.config
    and client.config.capabilities
    and client.config.capabilities.documentFormattingProvider == false
  then
    return
  end
  -- Enable completion triggered by <c-x><c-o> (not sure this is necessary with
  -- cmp plugin)
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  if client.config.name == "yamlls" and vim.bo.filetype == "helm" then
    vim.lsp.buf_detach_client(bufnr, client.id)
  end

  if client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end

  local format_on_save_group = vim.api.nvim_create_augroup("formatOnSave", {})

  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_clear_autocmds({ group = format_on_save_group, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = format_on_save_group,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({
          bufnr = bufnr,
        })
      end,
    })
  end
  vim.api.nvim_create_user_command("Format", function()
    vim.lsp.buf.format({ async = true })
  end, {})

  if client.server_capabilities.code_lens then
    vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
      buffer = bufnr,
      callback = vim.lsp.codelens.refresh,
    })
    vim.lsp.codelens.refresh()
  end

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  require("core.keymaps").lsp_mappings(bufnr)
end

M.setup = function()
  -- set up global mappings for diagnostics
  require("core.keymaps").lsp_diagnostic_mappings()

  -- Add completion and documentation capabilities for cmp completion
  ---@param opts table|nil
  local function create_capabilities(opts)
    local default_opts = {
      with_snippet_support = true,
    }
    opts = opts or default_opts
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = opts.with_snippet_support
    if opts.with_snippet_support then
      capabilities.textDocument.completion.completionItem.resolveSupport = {
        properties = {
          "documentation",
          "detail",
          "additionalTextEdits",
        },
      }
    end

    return cmp_lsp.default_capabilities(capabilities)
  end

  -- inject our custom on_attach after the built in on_attach from the lspconfig
  lspconfig.util.on_setup = lspconfig.util.add_hook_after(lspconfig.util.on_setup, function(config)
    if config.on_attach then
      config.on_attach = lspconfig.util.add_hook_after(config.on_attach, on_attach)
    else
      config.on_attach = on_attach
    end

    config.capabilities = create_capabilities()
  end)

  ---@diagnostic disable-next-line: redundant-parameter
  require("plugins.mason").setup({
    on_attach = on_attach,
  })

  elixir.setup({
    on_attach = on_attach,
  })
end

return M
