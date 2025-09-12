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
  if client.server_capabilities.documentSymbolProvider and navic_present then
    local ok, err = pcall(navic.attach, client, bufnr)
    if not ok then
      vim.notify("navic.attach error: " .. tostring(err), vim.log.levels.ERROR)
    end
  end

  if client.supports_method "textDocument/formatting" then
    local format_on_save_group = vim.api.nvim_create_augroup("formatOnSave", {})

    vim.api.nvim_clear_autocmds { group = format_on_save_group, buffer = bufnr }
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = format_on_save_group,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format { bufnr = bufnr }
      end,
    })
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
