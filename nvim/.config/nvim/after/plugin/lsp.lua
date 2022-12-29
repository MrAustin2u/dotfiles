---@diagnostic disable: unused-local
local lsp = require("lsp-zero")
local ok, nvim_status = pcall(require, "lsp-status")
if not ok then
  nvim_status = nil
end

local eslint_disabled_buffers = {}

local augroup_format = vim.api.nvim_create_augroup("LspFormatting", { clear = true })

local lsp_formatting = function(bufnr)
  local clients = vim.lsp.get_active_clients({ bufnr = bufnr })

  vim.lsp.buf.format({
    bufnr = bufnr,
    filter = function(client)
      if client.name == "eslint" then
        return not eslint_disabled_buffers[bufnr]
      end

      return client.name ~= "tsserver" and not eslint_disabled_buffers[bufnr]
    end,
  })
end

--[[ LSP ]]

lsp.preset("recommended")

lsp.ensure_installed({
  "cssls",
  "elixirls",
  "eslint",
  "graphql",
  "gopls",
  "html",
  "jsonls",
  "rust_analyzer",
  "sumneko_lua",
  "tailwindcss",
  "tsserver",
})

lsp.set_preferences({
  sign_icons = {},
})

lsp.setup_nvim_cmp({
  mapping = cmp_mappings,
})

lsp.on_attach(function(client, bufnr)
  local opts = { buffer = bufnr, remap = false }

  bufnr = tonumber(bufnr) or vim.api.nvim_get_current_buf()

  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")

  if nvim_status then
    nvim_status.on_attach(client)
  end

  -- keymaps
  vim.keymap.set("n", "gd", function()
    vim.lsp.buf.definition()
  end, opts)

  vim.keymap.set("n", "gt", function()
    vim.lsp.buf.type_definition()
  end, opts)

  vim.keymap.set("n", "gD", function()
    vim.lsp.buf.declaration()
  end, opts)

  vim.keymap.set("n", "K", function()
    vim.lsp.buf.hover()
  end, opts)

  vim.keymap.set("n", "<leader>vws", function()
    vim.lsp.buf.workspace_symbol()
  end, opts)

  vim.keymap.set("n", "<leader>vd", function()
    vim.diagnostic.open_float()
  end, opts)

  vim.keymap.set("n", "[d", function()
    vim.diagnostic.goto_next()
  end, opts)

  vim.keymap.set("n", "]d", function()
    vim.diagnostic.goto_prev()
  end, opts)

  vim.keymap.set("n", "<leader>ca", function()
    vim.lsp.buf.code_action()
  end, opts)

  vim.keymap.set("n", "<leader>vrr", function()
    vim.lsp.buf.references()
  end, opts)

  vim.keymap.set("n", "<leader>vrn", function()
    vim.lsp.buf.rename()
  end, opts)

  vim.keymap.set("i", "<C-h>", function()
    vim.lsp.buf.signature_help()
  end, opts)

  vim.keymap.set("n", "<leader>f", function()
    vim.lsp.buf.format()
  end, opts)

  if filetype ~= "lua" then
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "lsp:hover", buffer = 0, remap = false })
  end

  vim.bo.omnifunc = "v:lua.lsp.omnifunc"

  -- Set autocommands conditional on server_capabilities
  if client.server_capabilities.documentHighlightProvider then
    vim.cmd([[
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]])
  end

  if client.server_capabilities.codeLensProvider then
    vim.cmd([[
        augroup lsp_document_codelens
          au! * <buffer>
          autocmd BufEnter ++once         <buffer> lua require"vim.lsp.codelens".refresh()
          autocmd BufWritePost,CursorHold <buffer> lua require"vim.lsp.codelens".refresh()
        augroup END
      ]])
  end

  -- Attach any filetype specific options to the client
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_buf_create_user_command(bufnr, "LspFormatting", function()
      lsp_formatting(bufnr)
    end, {})

    vim.api.nvim_clear_autocmds({ group = augroup_format, buffer = bufnr })

    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup_format,
      buffer = bufnr,
      command = "LspFormatting",
    })
  end

  require("illuminate").on_attach(client)
end)

--[[ COMPLETION ]]

local cmp = require("cmp")
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
  ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
  ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
  ["<C-y>"] = cmp.mapping.confirm({ select = true }),
  ["<C-Space>"] = cmp.mapping.complete(),
})

lsp.setup()
