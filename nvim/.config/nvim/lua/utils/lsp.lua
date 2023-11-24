local Utils = require("utils")

local M = {}

M.get_clients = function(opts)
  local ret = {}

  ret = vim.lsp.get_active_clients(opts)

  if opts and opts.method then
    ret = vim.tbl_filter(function(client)
      return client.supports_method(opts.method, { bufnr = opts.bufnr })
    end, ret)
  end

  return opts and opts.filter and vim.tbl_filter(opts.filter, ret) or ret
end


function M.on_rename(from, to)
  local clients = M.get_clients()
  for _, client in ipairs(clients) do
    if client:supports_method("workspace/willRenameFiles") then
      local resp = client.request_sync("workspace/willRenameFiles", {
        files = {
          {
            oldUri = vim.uri_from_fname(from),
            newUri = vim.uri_from_fname(to),
          },
        },
      }, 1000)
      if resp and resp.result ~= nil then
        vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
      end
    end
  end
end

M.on_attach = function(on_attach)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local buffer = args.buf ---@type number
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      on_attach(client, buffer)
    end,
  })
end

M.get_config = function(server)
  local configs = require("lspconfig.configs")
  return rawget(configs, server)
end

M.formatter = function(opts)
  opts = opts or {}
  local filter = opts.filter or {}
  filter = type(filter) == "string" and { name = filter } or filter
  local ret = {
    name = "LSP",
    primary = true,
    priority = 1,
    format = function(buf)
      M.format(Utils.merge_maps(filter, { bufnr = buf }))
    end,
    sources = function(buf)
      local clients = M.get_clients(Utils.merge_maps(filter, { bufnr = buf }))
      local ret = vim.tbl_filter(function(client)
        return client.supports_method("textDocument/formatting")
            or client.supports_method("textDocument/rangeFormatting")
      end, clients)
      return vim.tbl_map(function(client)
        return client.name
      end, ret)
    end,
  }
  return Utils.merge_maps(ret, opts)
end

M.format = function(opts)
  opts = vim.tbl_deep_extend("force", {}, opts or {}, Utils.opts("nvim-lspconfig").format or {})
  local ok, conform = pcall(require, "conform")
  -- use conform for formatting with LSP when available,
  -- since it has better format diffing
  if ok then
    opts.formatters = {}
    opts.lsp_fallback = true
    conform.format(opts)
  else
    vim.lsp.buf.format(opts)
  end
end
return M
