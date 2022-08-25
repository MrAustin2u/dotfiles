local api, bo, cmd, lsp = vim.api, vim.bo, vim.cmd, vim.lsp
local uri_to_bufnr = vim.uri_to_bufnr
local vim_diagnostic = vim.diagnostic
local tbl_deep_extend = vim.tbl_deep_extend
local ok, nvim_status = pcall(require, "lsp-status")
if not ok then
  nvim_status = nil
end

local handlers = require "aa.lsp.handlers"

local utils = {}

local eslint_disabled_buffers = {}

-- track buffers that eslint can't format to use prettier instead
lsp.handlers["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
  local client = lsp.get_client_by_id(ctx.client_id)
  if not (client and client.name == "eslint") then
    goto done
  end

  for _, diagnostic in ipairs(result.diagnostics) do
    if diagnostic.message:find("The file does not match your project config") then
      local bufnr = uri_to_bufnr(result.uri)
      eslint_disabled_buffers[bufnr] = true
    end
  end

  ::done::
  return lsp.diagnostic.on_publish_diagnostics(nil, result, ctx, config)
end

local augroup_format = api.nvim_create_augroup("LspFormatting", { clear = true })

local lsp_formatting = function(bufnr)
  local clients = lsp.get_active_clients({ bufnr = bufnr })

  lsp.buf.format({
    bufnr = bufnr,
    filter = function(client)
      if client.name == "eslint" then
        return not eslint_disabled_buffers[bufnr]
      end

      if client.name == "null-ls" then
        return not aa.table.some(clients, function(_, other_client)
          return other_client.name == "eslint" and not eslint_disabled_buffers[bufnr]
        end)
      end

      return client.name ~= "tsserver" and not eslint_disabled_buffers[bufnr]
    end,
  })
end

-- diagnostic border opts
utils.border_opts = {
  border = "single",
  focusable = false,
  scope = "line",
}

utils.init = function(client)
  client.config.flags = client.config.flags or {}
  client.config.flags.allow_incremental_sync = true
end

-- [ lsp setup ] -----------------------------------------------------------
utils.on_attach = function(client, bufnr)
  bufnr = tonumber(bufnr) or api.nvim_get_current_buf()

  local filetype = api.nvim_buf_get_option(bufnr, "filetype")

  if nvim_status then
    nvim_status.on_attach(client)
  end

  -- keymaps
  aa.buf_nnoremap { "<leader>r", lsp.buf.rename }
  aa.buf_nnoremap { "<leader>ca", lsp.buf.code_action }
  aa.buf_nnoremap { "gd", lsp.buf.definition }
  aa.buf_nnoremap { "gD", lsp.buf.declaration }
  aa.buf_nnoremap { "gi", handlers.implementation }
  aa.buf_nnoremap { "gt", lsp.buf.type_definition }
  aa.buf_nnoremap { "<leader>dp", vim_diagnostic.goto_prev }
  aa.buf_nnoremap { "<leader>dn", vim_diagnostic.goto_next }
  aa.buf_nnoremap { "e", vim_diagnostic.open_float }
  aa.buf_nnoremap { "<space>f", lsp.buf.format }

  if filetype ~= "lua" then
    aa.buf_nnoremap { "K", lsp.buf.hover, { desc = "lsp:hover" } }
  end

  bo.omnifunc = "v:lua.lsp.omnifunc"

  -- Set autocommands conditional on server_capabilities
  if client.server_capabilities.documentHighlightProvider then
    cmd [[
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]]
  end


  if client.server_capabilities.codeLensProvider then
    cmd [[
        augroup lsp_document_codelens
          au! * <buffer>
          autocmd BufEnter ++once         <buffer> lua require"vim.lsp.codelens".refresh()
          autocmd BufWritePost,CursorHold <buffer> lua require"vim.lsp.codelens".refresh()
        augroup END
      ]]
  end

  -- Attach any filetype specific options to the client
  if client.supports_method("textDocument/formatting") then
    aa.buf_command(bufnr, "LspFormatting", function()
      lsp_formatting(bufnr)
    end)

    api.nvim_clear_autocmds({ group = augroup_format, buffer = bufnr })

    api.nvim_create_autocmd("BufWritePre", {
      group = augroup_format,
      buffer = bufnr,
      command = "LspFormatting",
    })
  end

  require("illuminate").on_attach(client)
end

utils.capabilities = function()
  local updated_capabilities = lsp.protocol.make_client_capabilities()

  if nvim_status then
    updated_capabilities = tbl_deep_extend("keep", updated_capabilities, nvim_status.capabilities)

    if updated_capabilities ~= nil then
      updated_capabilities.textDocument.codeLens = { dynamicRegistration = false }
    end

    updated_capabilities = require("cmp_nvim_lsp").update_capabilities(updated_capabilities)

    updated_capabilities.textDocument.completion.completionItem.snippetSupport = true
  end

  return updated_capabilities
end

return utils
