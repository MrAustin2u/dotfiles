local icons = require("config.utils").icons

-- Auto-discover LSP configs from lsp/*.lua files
local lsp_dir = vim.fn.stdpath "config" .. "/lsp"
local servers = {}

for name, type in vim.fs.dir(lsp_dir) do
  if type == "file" and name:sub(-4) == ".lua" then
    table.insert(servers, name:sub(1, -5))
  end
end

vim.lsp.enable(servers)

require("config.keymaps").lsp_diagnostic_mappings()

local lsp_group = vim.api.nvim_create_augroup("UserLspConfig", {})

vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_group,
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

    require("config.keymaps").lsp_mappings()

    -- Attach nvim-navic if available and client supports documentSymbolProvider
    local has_navic, navic = pcall(require, "nvim-navic")
    if has_navic and client.server_capabilities.documentSymbolProvider then
      navic.attach(client, ev.buf)
    end
  end,
})

-- LSP servers are managed by mise
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
  virtual_text = {
    severity = { min = vim.diagnostic.severity.WARN },
    spacing = 4,
    prefix = "●",
  },
  float = {
    border = "rounded",
    source = true,
  },
  update_in_insert = false,
  severity_sort = true,
}

-- Cap hover and signature help window sizes
local hover = vim.lsp.buf.hover
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.buf.hover = function()
  return hover {
    max_height = math.floor(vim.o.lines * 0.5),
    max_width = math.floor(vim.o.columns * 0.4),
    border = "rounded",
  }
end

local signature_help = vim.lsp.buf.signature_help
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.buf.signature_help = function()
  return signature_help {
    max_height = math.floor(vim.o.lines * 0.5),
    max_width = math.floor(vim.o.columns * 0.4),
    border = "rounded",
  }
end
