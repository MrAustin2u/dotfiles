local LSP = require "config.utils.lsp"
local UTILS = require "config.utils"

local lspconfig_present, lspconfig = pcall(require, "lspconfig")

local deps = {
  lspconfig_present,
}

if UTILS.contains(deps, false) then
  vim.notify "Failed to load dependencies in plugins/lsp.lua"
  return
end

local M = {}

M.on_attach = function(_client, bufnr)
  LSP.on_supports_method("textDocument/inlayHint", function(_, buffer)
    if vim.api.nvim_buf_is_valid(buffer) and vim.bo[buffer].buftype == "" then
      vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
    end
  end)

  if vim.lsp.codelens then
    LSP.on_supports_method("textDocument/codeLens", function(_c, buffer)
      vim.lsp.codelens.refresh()
      vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
        buffer = buffer,
        callback = vim.lsp.codelens.refresh,
      })
    end)
  end

  require("config.keymaps").lsp_mappings(bufnr)
end

-- Add completion and documentation capabilities for cmp completion
M.create_capabilities = function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  if pcall(require, "cmp_nvim_lsp") then
    capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
  end
  return capabilities
end

M.setup_diagnostics = function()
  for name, icon in pairs(require("config.icons").diagnostics) do
    name = "DiagnosticSign" .. name
    vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
  end

  local diagnostic_config = {
    underline = true,
    update_in_insert = false,
    virtual_text = {
      spacing = 4,
      source = "if_many",
      prefix = "●",
    },
    severity_sort = true,
    float = {
      border = "rounded",
    },
  }

  vim.diagnostic.config(diagnostic_config)
end

M.setup = function()
  -- set up global mappings for diagnostics
  require("config.keymaps").lsp_diagnostic_mappings()

  M.setup_diagnostics()

  -- inject our custom on_attach after the built in on_attach from the lspconfig
  lspconfig.util.on_setup = lspconfig.util.add_hook_after(lspconfig.util.on_setup, function(config)
    if config.on_attach then
      config.on_attach = lspconfig.util.add_hook_after(config.on_attach, M.on_attach)
    else
      config.on_attach = M.on_attach
    end

    config.capabilities = M.create_capabilities()
  end)
end

return M
