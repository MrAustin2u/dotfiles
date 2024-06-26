local TELESCOPE = require("config.utils.telescope")
local TOGGLE = require("config.utils.toggle")
local UTILS = require("config.utils")

local M = {}

function M.lsp_keymaps(bufnr)
  local opts = { noremap = true, silent = true }
  local keymap = vim.api.nvim_buf_set_keymap
  keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
  vim.keymap.set("n", "gd", TELESCOPE.telescope("lsp_definitions"), opts)
  keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  keymap(bufnr, "n", "gI", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  vim.keymap.set("n", "gr", TELESCOPE.telescope("lsp_references"), opts)
  keymap(bufnr, "n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
  keymap(bufnr, "n", "fs", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
  keymap(bufnr, "n", "<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
  keymap(bufnr, "n", "<leader>bf", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", opts)
  keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  keymap(bufnr, "n", "<leader>li", "<cmd>LspInfo<cr>", opts)
  keymap(bufnr, "n", "<leader>lr", "<cmd>LspRestart<cr>", opts)

  -- if vim.lsp.inlay_hint then
  --   vim.keymap.set("n", "<leader>lh", function()
  --     vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ buffer = bufnr }))
  --   end, UTILS.merge_maps(opts, { desc = "Toggle Inlay Hints" }))
  -- end
end

local format_on_save_group = vim.api.nvim_create_augroup("formatOnSave", {})
function M.on_attach(client, bufnr)
  if client.supports_method("textDocument/formatting", { bufnr = bufnr }) then
    vim.api.nvim_clear_autocmds({ group = format_on_save_group, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = format_on_save_group,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ bufnr = bufnr })
      end,
    })
  end

  -- if vim.fn.has("nvim-0.10") == 1 and client.supports_method("textDocument/codeLens", { bufnr = bufnr }) and vim.lsp.inlay_hint then
  --   TOGGLE.inlay_hints(bufnr, true)
  -- end

  -- code lens
  -- if client.supports_method("textDocument/codeLens", { bufnr = bufnr }) then
  --   vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
  --     buffer = bufnr,
  --     callback = vim.lsp.codelens.refresh,
  --   })
  -- end
end

function M.common_capabilities()
  local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  return capabilities
end

function M.lsp_diagnostics()
  local icons = require("config.icons")
  local default_diagnostic_config = {
    float = { border = "rounded" },
    severity_sort = true,
    signs = {
      active = true,
      values = {
        { name = "DiagnosticSignError", text = icons.diagnostics.Error },
        { name = "DiagnosticSignWarn",  text = icons.diagnostics.Warning },
        { name = "DiagnosticSignHint",  text = icons.diagnostics.Hint },
        { name = "DiagnosticSignInfo",  text = icons.diagnostics.Information },
      },
    },
    underline = true,
    update_in_insert = false,
    virtual_text = {
      spacing = 4,
      source = 'if_many',
      prefix = '●'
    },
  }

  vim.diagnostic.config(default_diagnostic_config)
end

function M.lsp_diagnostic_mappings()
  local function diagnostic_goto(next, severity)
    local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
    severity = severity and vim.diagnostic.severity[severity] or nil
    return function()
      go({ severity = severity })
    end
  end

  vim.keymap.set("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
  vim.keymap.set("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
  vim.keymap.set("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
  vim.keymap.set("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
  vim.keymap.set("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
  vim.keymap.set("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })
end

return M
