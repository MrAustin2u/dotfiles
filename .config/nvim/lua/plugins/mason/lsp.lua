local lspconfig_present, lspconfig = pcall(require, "lspconfig")
local navic_present, navic = pcall(require, "nvim-navic")
local cmp_present, blink = pcall(require, "blink.cmp")

local deps = {
  lspconfig_present,
  navic_present,
  cmp_present,
}

if aa.contains(deps, false) then
  vim.notify "Failed to load dependencies in plugins/lsp.lua"
  return
end

local M = {}

M.on_attach = function(client, bufnr)
  local client_name = client.config.name
  local ft = vim.bo.filetype

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

  if vim.fn.has "nvim-0.10" == 1 then
    -- inlay hints
    aa.lsp.on_supports_method("textDocument/inlayHint", function(client, buffer)
      if
          vim.api.nvim_buf_is_valid(buffer)
          and vim.bo[buffer].buftype == ""
          and not vim.tbl_contains({ "vue" }, vim.bo[buffer].filetype)
      then
        vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
      end
    end)

    -- code lens
    aa.lsp.on_supports_method("textDocument/codeLens", function(client, buffer)
      vim.lsp.codelens.refresh()
      vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
        buffer = buffer,
        callback = vim.lsp.codelens.refresh,
      })
    end)
  end

  -- /BEGIN: Helm file support
  if client_name == "yamlls" and ft == "helm" then
    vim.lsp.stop_client(client.id)
    vim.lsp.buf_detach_client(bufnr, client.id)
  end

  if vim.bo[bufnr].buftype ~= "" or ft == "helm" then
    vim.diagnostic.enable(false, bufnr)
    -- remove existing diagnostic messages that appear about a second after load
    -- (in the status bar). They do end up coming back though after awhile, not
    -- sure why
    vim.defer_fn(function()
      vim.diagnostic.reset(nil, bufnr)
    end, 2000)
  end
  -- /END: Helm file support

  -- support for lsp based breadcrumbs
  if client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  require("config.keymaps").lsp_mappings()
end

-- Add completion and documentation capabilities for cmp completion
M.create_capabilities = function()
  local capabilities = vim.tbl_deep_extend(
    "force",
    {},
    vim.lsp.protocol.make_client_capabilities(),
    cmp_present and blink.get_lsp_capabilities() or {}
  )

  return capabilities
end

M.setup_diagnostics = function()
  for name, icon in pairs(aa.icons.diagnostics) do
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
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = aa.icons.diagnostics.Error,
        [vim.diagnostic.severity.WARN] = aa.icons.diagnostics.Warn,
        [vim.diagnostic.severity.HINT] = aa.icons.diagnostics.Hint,
        [vim.diagnostic.severity.INFO] = aa.icons.diagnostics.Info,
      },
    },
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
