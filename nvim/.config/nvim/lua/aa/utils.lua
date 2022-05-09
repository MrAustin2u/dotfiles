local api = vim.api
local fn, vcmd, lsp = vim.fn, vim.cmd, vim.lsp
local au = aa.au

local utils = {
  lsp = {},
}

-- # [ lsp diagnostics ] -----------------------------------------------------------
local serverity_map = {
  "DiagnosticError",
  "DiagnosticWarn",
  "DiagnosticInfo",
  "DiagnosticHint",
}
local icon_map = {
  "  ",
  "  ",
  "  ",
  "  ",
}

local function source_string(source)
  return string.format("  [%s]", source)
end

utils.wrap_lines = function(input, width)
  local output = {}
  for _, line in ipairs(input) do
    line = line:gsub("\r", "")
    while #line > width + 2 do
      local trimmed_line = string.sub(line, 1, width)
      local index = trimmed_line:reverse():find(" ")
      if index == nil or index > #trimmed_line / 2 then
        break
      end
      table.insert(output, string.sub(line, 1, width - index))
      line = vim.o.showbreak .. string.sub(line, width - index + 2, #line)
    end
    table.insert(output, line)
  end

  return output
end

utils.lsp.line_diagnostics = function()
  local width = 70
  local bufnr, lnum = unpack(fn.getcurpos())
  local diagnostics = vim.lsp.diagnostic.get_line_diagnostics(bufnr, lnum - 1, {})
  if vim.tbl_isempty(diagnostics) then
    return
  end

  local lines = {}

  for _, diagnostic in ipairs(diagnostics) do
    table.insert(
      lines,
      icon_map[diagnostic.severity]
      .. " "
      .. diagnostic.message:gsub("\n", " ")
      .. source_string(diagnostic.source)
    )
  end

  local floating_bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(floating_bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(floating_bufnr, "filetype", "diagnosticpopup")

  for i, diagnostic in ipairs(diagnostics) do
    local message_length = #lines[i] - #source_string(diagnostic.source)
    vim.api.nvim_buf_add_highlight(floating_bufnr, -1, serverity_map[diagnostic.severity], i - 1, 0, message_length)
    vim.api.nvim_buf_add_highlight(floating_bufnr, -1, "DiagnosticSource", i - 1, message_length, -1)
  end

  local winnr = vim.api.nvim_open_win(floating_bufnr, false, {
    relative = "cursor",
    width = width,
    height = #utils.wrap_lines(lines, width - 1),
    row = 1,
    col = 1,
    style = "minimal",
    border = vim.g.floating_window_border_dark,
  })

  vim.lsp.util.close_preview_autocmd(
    { "CursorMoved", "CursorMovedI", "BufHidden", "BufLeave", "WinScrolled", "InsertCharPre" },
    winnr
  )
end

---Override diagnostics signs helper to only show the single most relevant sign
---@see: http://reddit.com/r/neovim/comments/mvhfw7/can_built_in_lsp_diagnostics_be_limited_to_show_a
---@param diagnostics table[]
---@return table[]
utils.lsp.filter_diagnostics = function(diagnostics, _)
  if not diagnostics then
    return {}
  end
  -- Work out max severity diagnostic per line
  local max_severity_per_line = {}
  for _, d in pairs(diagnostics) do
    local lnum = d.lnum
    if max_severity_per_line[lnum] then
      local current_d = max_severity_per_line[lnum]
      if d.severity < current_d.severity then
        max_severity_per_line[lnum] = d
      end
    else
      max_severity_per_line[lnum] = d
    end
  end
  -- map to list
  local filtered_diagnostics = {}
  for _, v in pairs(max_severity_per_line) do
    table.insert(filtered_diagnostics, v)
  end
  return filtered_diagnostics
end

-- [ module loaders ] -----------------------------------------------------------
utils.has_module = function(name)
  if pcall(function()
    require(name)
  end) then
    return true
  else
    return false
  end
end

utils.border_opts = {
  border = "single",
  focusable = false,
  scope = "line",
}

local function lsp_highlight_document(client)
  if client.server_capabilities.document_highlight then
    local status_ok, illuminate = pcall(require, "illuminate")
    if not status_ok then
      return
    end
    illuminate.on_attach(client)
  end
end

local lsp_formatting = function(bufnr)
  local formatting_clients = { "eslint_d", "eslint", "null-ls" }
  lsp.buf.format({
    bufnr = bufnr,
    filter = function(clients)
      return vim.tbl_filter(function(client)
        if vim.tbl_contains(formatting_clients, client.name) then
          return true
        end
        if client.name == "null-ls" then
          return not aa.table.some(clients, function(_, other_client)
            return vim.tbl_contains(formatting_clients, other_client.name)
          end)
        end
      end, clients)
    end,
  })
end

local function lsp_keymaps(bufnr)
  aa.buf_command(bufnr, "LspFormatting", vim.lsp.buf.format)
  aa.buf_command(bufnr, "LspHover", vim.lsp.buf.hover)
  aa.buf_command(bufnr, "LspRename", vim.lsp.buf.rename)
  aa.buf_command(bufnr, "LspTypeDef", vim.lsp.buf.type_definition)
  aa.buf_command(bufnr, "LspDiagLine", vim.diagnostic.open_float)
  aa.buf_command(bufnr, "LspDiagPrev", vim.diagnostic.goto_prev)
  aa.buf_command(bufnr, "LspDiagNext", vim.diagnostic.goto_next)
  aa.buf_command(bufnr, "LspCodeAct", vim.lsp.buf.code_action)

  aa.buf_map(bufnr, "n", "gi", ":LspRename<CR>")
  aa.buf_map(bufnr, "n", "gy", ":LspTypeDef<CR>")
  aa.buf_map(bufnr, "n", "[a", ":LspDiagPrev<CR>")
  aa.buf_map(bufnr, "n", "]a", ":LspDiagNext<CR>")
  aa.buf_map(bufnr, "n", "K", ":LspHover<CR>")
  aa.buf_map(bufnr, "n", "e", ":LspDiagLine<CR>")
  aa.buf_map(bufnr, "v", "ca", "<Esc><cmd> LspCodeAct<CR>")
  aa.buf_map(bufnr, "n", "<space>f", ":LspFormatting<CR>")
end

-- [ lsp setup ] -----------------------------------------------------------
utils.lsp.on_attach = function(client, bufnr)
  require("lsp-status").on_attach(client)

  if client.server_capabilities.code_lens then
    au("CursorHold,CursorHoldI,InsertLeave <buffer> lua vim.lsp.codelens.refresh()")
  end

  if client.supports_method("textDocument/formatting") then
    aa.buf_command(bufnr, "LspFormatting", function()
      lsp_formatting(bufnr)
    end)

    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = bufnr,
      command = "LspFormatting",
    })
  end

  lsp_keymaps(bufnr)
  lsp_highlight_document(client)
end

utils.lsp.capabilities = function()
  local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  return capabilities
end

utils.lsp.defaults = function(opts)
  opts = opts or {}
  local config = vim.tbl_deep_extend("force", opts, {
    autorstart = true,
    on_attach = utils.lsp.on_attach,
    capabilities = utils.lsp.capabilities(),
    flags = { debounce_text_changes = 150 },
    root_dir = vim.loop.cwd,
  })

  return config
end

-- [ save and formatting ] -----------------------------------------------------------
utils.save_and_source = function()
  if vim.bo.filetype == "vim" then
    vcmd("silent! write")
    vcmd("source %")
    aa.log("Saving and sourcing vim file...")
  elseif vim.bo.filetype == "lua" then
    vcmd("silent! write")
    vcmd("luafile %")
    aa.log("Saving and sourcing lua file...")
  end
end

utils.lsp.formatting = function(bufnr)
  local preferred_formatting_clients = { "eslint", "eslint_d", "tsserver" }
  local fallback_formatting_client = "null-ls"

  -- prevent repeated lookups
  local buffer_client_ids = {}

  bufnr = tonumber(bufnr) or api.nvim_get_current_buf()

  local selected_client
  if buffer_client_ids[bufnr] then
    selected_client = lsp.get_client_by_id(buffer_client_ids[bufnr])
  else
    for _, client in pairs(lsp.buf_get_clients(bufnr)) do
      if vim.tbl_contains(preferred_formatting_clients, client.name) then
        selected_client = client
        break
      end

      if client.name == fallback_formatting_client then
        selected_client = client
      end
    end
  end

  if not selected_client then
    return
  end

  buffer_client_ids[bufnr] = selected_client.id

  local params = lsp.util.make_formatting_params()
  selected_client.request("textDocument/formatting", params, function(err, res)
    if err then
      local err_msg = type(err) == "string" and err or err.message
      vim.notify("global.lsp.formatting: " .. err_msg, vim.log.levels.WARN)
      return
    end

    if not api.nvim_buf_is_loaded(bufnr) or api.nvim_buf_get_option(bufnr, "modified") then
      return
    end

    if res then
      lsp.util.apply_text_edits(res, bufnr, selected_client.offset_encoding or "utf-16")
      api.nvim_buf_call(bufnr, function()
        vcmd("silent! noautocmd update")
      end)
    end
  end, bufnr)
end

-- [ files/paths ] -----------------------------------------------------------
utils.root_has_file = function(name)
  local cwd = vim.loop.cwd()
  local lsputil = require("lspconfig.util")
  return lsputil.path.exists(lsputil.path.join(cwd, name)), lsputil.path.join(cwd, name)
end

-- [ misc. ] -----------------------------------------------------------
utils.termcodes = function(str)
  return api.nvim_replace_termcodes(str, true, true, true)
end

return utils
