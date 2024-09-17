local M = {}

M.on_attach = function(client, bufnr)
  if client.supports_method "textDocument/formatting" then
    local format_on_save_group = vim.api.nvim_create_augroup("formatOnSave", {})
    vim.api.nvim_clear_autocmds { group = format_on_save_group, buffer = bufnr }
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = format_on_save_group,
      buffer = bufnr,
      callback = function(_args)
        require("conform").format {
          bufnr = bufnr,
          lsp_fallback = true,
          quiet = true,
        }
      end,
    })
  end

  if client.server_capabilities.code_lens then
    vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
      buffer = bufnr,
      callback = vim.lsp.codelens.refresh,
    })
    vim.lsp.codelens.refresh()
  end
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
  require("config.keymaps").lsp_diagnostic_mappings()
end

M.create_capabilities = function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  if pcall(require, "cmp_nvim_lsp") then
    capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
  end
  return capabilities
end

M.lsp_attach = function()
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(event)
      local client = vim.lsp.get_client_by_id(event.data.client_id)

      M.setup_diagnostics()
      require("config.keymaps").lsp_mappings(event.buf)

      vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"

      if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
        require("config.keymaps").lsp_inlay_hints_mappings(event.buf)
      end
    end,
  })
end

return M
