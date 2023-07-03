local utils = require("utils")

local lspconfig_present, lspconfig = pcall(require, "lspconfig")
local cmp_lsp_present, cmp_lsp = pcall(require, "cmp_nvim_lsp")
local elixir_present, elixir = pcall(require, "elixir")

local deps = {
  cmp_lsp_present,
  lspconfig_present,
  elixir_present,
}

if utils.contains(deps, false) then
  vim.notify("Failed to load dependencies in plugins/lsp.lua")
  return
end

local M = {}

local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o> (not sure this is necessary with
  -- cmp plugin)
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  if client.config.name == "yamlls" and vim.bo.filetype == "helm" then
    vim.lsp.buf_detach_client(bufnr, client.id)
  end

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  require("keymaps").lsp_mappings(bufnr)
end

M.setup = function()
  -- set up global mappings for diagnostics
  require("keymaps").lsp_diagnostic_mappings()

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
  require("plugins.lsp.mason").setup({
    on_attach = on_attach,
  })

  elixir.setup({
    elixirls = {
      enabled = true,
      on_attach = function(client, bufnr)
        vim.keymap.set("n", "<space>fp", ":ElixirFromPipe<cr>", { buffer = true, noremap = true })
        vim.keymap.set("n", "<space>tp", ":ElixirToPipe<cr>", { buffer = true, noremap = true })
        vim.keymap.set("v", "<space>em", ":ElixirExpandMacro<cr>", { buffer = true, noremap = true })
        on_attach(client, bufnr)
      end,
    },
  })
end

return M