local api = vim.api
local fn, vcmd = vim.fn, vim.cmd
local utils = {
  lsp = {}
}

-- # [ diagnostics ] -----------------------------------------------------------
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
      icon_map[diagnostic.severity] .. " " .. diagnostic.message:gsub("\n", " ") .. source_string(diagnostic.source)
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
---@param bufnr number
---@return table[]
utils.lsp.filter_diagnostics = function(diagnostics, bufnr)
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

-- module loaders -----------------------------------------------------------
utils.has_module = function(name)
  if
    pcall(
      function()
        require(name)
      end
    )
   then
    return true
  else
    return false
  end
end

-- save and formatting -----------------------------------------------------------
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

utils.lsp.autoformat = true

utils.lsp.format_toggle = function()
  utils.lsp.autoformat = not utils.lsp.autoformat
  if utils.lsp.autoformat then
    aa.log("enabled format on save", nil, "Formatting")
  else
    aa.warn("disabled format on save", "Formatting")
  end
end

utils.lsp.format = function()
  if utils.lsp.autoformat then
    vim.lsp.buf.formatting_sync()
  end
end

utils.lsp.format_setup = function(client, buf)
  local ft = vim.api.nvim_buf_get_option(buf, "filetype")
  local nls = aa.load("aa.plugins.null-ls")

  local enable = false
  if nls.has_formatter(ft) then
    enable = client.name == "null-ls"
  else
    enable = not client.name == "null-ls"
  end

  client.resolved_capabilities.document_formatting = enable

  -- format on save
  if client.resolved_capabilities.document_formatting then
    vim.cmd([[
      augroup LspFormat
        autocmd! * <buffer>
        autocmd BufWritePre <buffer> lua require("aa.utils").lsp.format()
      augroup END
    ]])
  end
end

-- files/paths -----------------------------------------------------------
utils.root_has_file = function(name)
  local cwd = vim.loop.cwd()
  local lsputil = require("lspconfig.util")
  return lsputil.path.exists(lsputil.path.join(cwd, name)), lsputil.path.join(cwd, name)
end

-- misc. -----------------------------------------------------------
utils.termcodes = function (str)
  return api.nvim_replace_termcodes(str, true, true, true)
end


return utils
