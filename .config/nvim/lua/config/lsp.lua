local lspconfig_present, _lspconfig = pcall(require, "lspconfig")
local navic_present, navic = pcall(require, "nvim-navic")

local deps = {
  lspconfig_present,
  navic_present,
}

if require("config.utils").contains(deps, false) then
  vim.notify "Failed to load dependencies in plugins/lsp.lua"
  return
end

local M = {}

M.on_attach = function(client, bufnr)
  if client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end

  require("config.keymaps").lsp_mappings()
end
M.setup = function()
  require("config.keymaps").lsp_diagnostic_mappings()

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp", {}),
    callback = function(ev)
      local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

      local existing_capabilities = client.config.capabilities or vim.lsp.protocol.make_client_capabilities()
      -- merge blink cmp capabilities
      client.config.capabilities = require("blink.cmp").get_lsp_capabilities(existing_capabilities)

      M.on_attach(client, ev.buf)
    end,
  })
end

return M
