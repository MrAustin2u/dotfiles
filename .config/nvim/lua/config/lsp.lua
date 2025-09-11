local icons = require("config.utils").icons

vim.lsp.enable {
  "dockerls",
  "dprint",
  "elixirls",
  "erlangls",
  "eslint",
  "expert",
  "gleam",
  "gopls",
  "graphql",
  "html",
  "json",
  "jsonls",
  "lexical",
  "lua_ls",
  "marksman",
  "pyright",
  "sqlls",
  "tailwindcss",
  "terraformls",
  "ts_ls",
  "typos_lsp",
  "vtsls",
  "yammls",
}

vim.diagnostic.config {
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = icons.Error,
      [vim.diagnostic.severity.WARN] = icons.Warn,
      [vim.diagnostic.severity.INFO] = icons.Info,
      [vim.diagnostic.severity.HINT] = icons.Hint,
    },
  },
  virtual_lines = { current_line = true },
  severity_sort = true,
  virtual_text = false,
  float = {
    border = "rounded",
    source = true,
  },
}
require("config.keymaps").lsp_diagnostic_mappings()

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp", {}),
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

    if
      not client:supports_method "textDocument/willSaveWaitUntil"
      and client:supports_method "textDocument/formatting"
    then
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("my.lsp", { clear = false }),
        buffer = ev.buf,
        callback = function()
          vim.lsp.buf.format { bufnr = ev.buf, id = client.id, timeout_ms = 1000 }
        end,
      })
    end

    require("config.keymaps").lsp_mappings()
  end,
})
