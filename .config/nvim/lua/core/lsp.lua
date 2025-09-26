local icons = require("config.utils").icons
local lsp_servers = require("config.utils").lsp_servers

-- LSP server configurations (manually loaded since we're using a dotfiles structure)

-- Load LSP configurations manually (since we're in a dotfiles structure)
for _, server in ipairs(lsp_servers) do
  local config_file = vim.fn.stdpath "config" .. "/lsp/" .. server .. ".lua"
  if vim.fn.filereadable(config_file) == 1 then
    local ok, config = pcall(dofile, config_file)
    if ok and config then
      vim.lsp.config[server] = config
    else
      vim.notify("Failed to parse LSP config for " .. server .. ": " .. tostring(config), vim.log.levels.ERROR)
    end
  else
    vim.notify("LSP config file not found for " .. server .. ": " .. config_file, vim.log.levels.WARN)
  end
end

-- Enable all configured LSP servers
vim.lsp.enable(lsp_servers)

require("config.keymaps").lsp_diagnostic_mappings()

local function setup_format_on_save(client, bufnr)
  if not client.supports_method "textDocument/formatting" then
    return
  end

  local group = vim.api.nvim_create_augroup("formatOnSave_" .. bufnr, { clear = true })
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = group,
    buffer = bufnr,
    callback = function()
      vim.lsp.buf.format { bufnr = bufnr, id = client.id }
    end,
  })
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp", {}),
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

    setup_format_on_save(client, ev.buf)
    require("config.keymaps").lsp_mappings()

    -- Attach nvim-navic if available and client supports documentSymbolProvider
    local has_navic, navic = pcall(require, "nvim-navic")
    if has_navic and client.server_capabilities.documentSymbolProvider then
      navic.attach(client, ev.buf)
    end
  end,
})

-- LSP lsp_servers are managed by mise
-- Use `mise ls` to check which LSPs are available

vim.diagnostic.config {
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
      [vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
      [vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
      [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
    },
  },
  virtual_text = true,
  float = {
    border = "rounded",
    source = true,
  },
  update_in_insert = false,
  severity_sort = true,
}
