local icons = require("config.utils").icons

-- LSP server configurations (manually loaded since we're using a dotfiles structure)
local servers = {
  "angularls",
  "biome",
  "cssls",
  "dockerls",
  "dprint",
  "erlangls",
  "eslint",
  "expert",
  "gleam",
  "gopls",
  "graphql",
  "html",
  "json",
  "jsonls",
  "lua_ls",
  "marksman",
  "pyright",
  "sqlls",
  "tailwindcss",
  "terraformls",
  "vtsls", -- Use vtsls instead of ts_ls to avoid conflicts
  "typos_lsp",
  "yamlls",
}

-- Load LSP configurations manually (since we're in a dotfiles structure)
for _, server in ipairs(servers) do
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
vim.lsp.enable(servers)

require("config.keymaps").lsp_diagnostic_mappings()

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp", {}),
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

    if client.supports_method "textDocument/formatting" then
      local format_on_save_group = vim.api.nvim_create_augroup("formatOnSave", {})

      vim.api.nvim_clear_autocmds { group = format_on_save_group, buffer = ev.buf }
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = format_on_save_group,
        buffer = ev.buf,
        callback = function()
          vim.lsp.buf.format { bufnr = ev.buf, id = client.id }
        end,
      })
    end

    require("config.keymaps").lsp_mappings()
  end,
})

-- LSP servers are automatically managed by Mason
-- Use :MasonVerify to check which tools are Mason-managed

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

-- Extras

local function restart_lsp(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients { bufnr = bufnr }

  for _, client in ipairs(clients) do
    vim.lsp.stop_client(client.id)
  end

  vim.defer_fn(function()
    vim.cmd "edit"
  end, 100)
end

vim.api.nvim_create_user_command("LspRestart", function()
  restart_lsp()
end, {})

local function lsp_status()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients { bufnr = bufnr }

  if #clients == 0 then
    print "󰅚 No LSP clients attached"
    return
  end

  print("󰒋 LSP Status for buffer " .. bufnr .. ":")
  print "─────────────────────────────────"

  for i, client in ipairs(clients) do
    print(string.format("󰌘 Client %d: %s (ID: %d)", i, client.name, client.id))
    print("  Root: " .. (client.config.root_dir or "N/A"))
    local filetypes = client.config.filetypes or client.server_capabilities.filetypes or {}
    print("  Filetypes: " .. table.concat(filetypes, ", "))

    -- Check capabilities
    local caps = client.server_capabilities
    local features = {}
    if caps and caps.completionProvider then
      table.insert(features, "completion")
    end
    if caps and caps.hoverProvider then
      table.insert(features, "hover")
    end
    if caps and caps.definitionProvider then
      table.insert(features, "definition")
    end
    if caps and caps.referencesProvider then
      table.insert(features, "references")
    end
    if caps and caps.renameProvider then
      table.insert(features, "rename")
    end
    if caps and caps.codeActionProvider then
      table.insert(features, "code_action")
    end
    if caps and caps.documentFormattingProvider then
      table.insert(features, "formatting")
    end

    print("  Features: " .. table.concat(features, ", "))
    print ""
  end
end

vim.api.nvim_create_user_command("LspStatus", lsp_status, { desc = "Show detailed LSP status" })

local function check_lsp_capabilities()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients { bufnr = bufnr }

  if #clients == 0 then
    print "No LSP clients attached"
    return
  end

  for _, client in ipairs(clients) do
    print("Capabilities for " .. client.name .. ":")
    local caps = client.server_capabilities

    local capability_list = {
      { "Completion",                caps and caps.completionProvider },
      { "Hover",                     caps and caps.hoverProvider },
      { "Signature Help",            caps and caps.signatureHelpProvider },
      { "Go to Definition",          caps and caps.definitionProvider },
      { "Go to Declaration",         caps and caps.declarationProvider },
      { "Go to Implementation",      caps and caps.implementationProvider },
      { "Go to Type Definition",     caps and caps.typeDefinitionProvider },
      { "Find References",           caps and caps.referencesProvider },
      { "Document Highlight",        caps and caps.documentHighlightProvider },
      { "Document Symbol",           caps and caps.documentSymbolProvider },
      { "Workspace Symbol",          caps and caps.workspaceSymbolProvider },
      { "Code Action",               caps and caps.codeActionProvider },
      { "Code Lens",                 caps and caps.codeLensProvider },
      { "Document Formatting",       caps and caps.documentFormattingProvider },
      { "Document Range Formatting", caps and caps.documentRangeFormattingProvider },
      { "Rename",                    caps and caps.renameProvider },
      { "Folding Range",             caps and caps.foldingRangeProvider },
      { "Selection Range",           caps and caps.selectionRangeProvider },
    }

    for _, cap in ipairs(capability_list) do
      local status = cap[2] and "✓" or "✗"
      print(string.format("  %s %s", status, cap[1]))
    end
    print ""
  end
end

vim.api.nvim_create_user_command("LspCapabilities", check_lsp_capabilities, { desc = "Show LSP capabilities" })

local function lsp_diagnostics_info()
  local bufnr = vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(bufnr)

  local counts = { ERROR = 0, WARN = 0, INFO = 0, HINT = 0 }

  for _, diagnostic in ipairs(diagnostics) do
    local severity = vim.diagnostic.severity[diagnostic.severity]
    counts[severity] = counts[severity] + 1
  end

  print "󰒡 Diagnostics for current buffer:"
  print("  Errors: " .. counts.ERROR)
  print("  Warnings: " .. counts.WARN)
  print("  Info: " .. counts.INFO)
  print("  Hints: " .. counts.HINT)
  print("  Total: " .. #diagnostics)
end

vim.api.nvim_create_user_command("LspDiagnostics", lsp_diagnostics_info, { desc = "Show LSP diagnostics count" })

local function lsp_info()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients { bufnr = bufnr }

  print "═══════════════════════════════════"
  print "           LSP INFORMATION          "
  print "═══════════════════════════════════"
  print ""

  -- Basic info
  print("󰈙 Language client log: " .. vim.lsp.get_log_path())
  print("󰈔 Detected filetype: " .. vim.bo.filetype)
  print("󰈮 Buffer: " .. bufnr)
  print("󰈔 Root directory: " .. (vim.fn.getcwd() or "N/A"))
  print ""

  if #clients == 0 then
    print("󰅚 No LSP clients attached to buffer " .. bufnr)
    print ""
    print "Possible reasons:"
    print("  • No language server installed for " .. vim.bo.filetype)
    print "  • Language server not configured"
    print "  • Not in a project root directory"
    print "  • File type not recognized"
    return
  end

  print("󰒋 LSP clients attached to buffer " .. bufnr .. ":")
  print "─────────────────────────────────"

  for i, client in ipairs(clients) do
    print(string.format("󰌘 Client %d: %s", i, client.name))
    print("  ID: " .. client.id)
    print("  Root dir: " .. (client.config.root_dir or "Not set"))
    local cmd = client.config.cmd or {}
    if type(cmd) == "function" then
      cmd = { "<function>" }
    end
    print("  Command: " .. table.concat(cmd, " "))
    local filetypes = client.config.filetypes or client.server_capabilities.filetypes or {}
    print("  Filetypes: " .. table.concat(filetypes, ", "))

    -- Server status
    if client.is_stopped then
      print "  Status: 󰅚 Stopped"
    else
      print "  Status: 󰄬 Running"
    end

    -- Workspace folders
    if client.workspace_folders and #client.workspace_folders > 0 then
      print "  Workspace folders:"
      for _, folder in ipairs(client.workspace_folders) do
        print("    • " .. folder.name)
      end
    end

    -- Attached buffers count
    local attached_buffers = {}
    for buf, _ in pairs(client.attached_buffers or {}) do
      table.insert(attached_buffers, buf)
    end
    print("  Attached buffers: " .. #attached_buffers)

    -- Key capabilities
    local caps = client.server_capabilities
    local key_features = {}
    if caps and caps.completionProvider then
      table.insert(key_features, "completion")
    end
    if caps and caps.hoverProvider then
      table.insert(key_features, "hover")
    end
    if caps and caps.definitionProvider then
      table.insert(key_features, "definition")
    end
    if caps and caps.documentFormattingProvider then
      table.insert(key_features, "formatting")
    end
    if caps and caps.codeActionProvider then
      table.insert(key_features, "code_action")
    end

    if #key_features > 0 then
      print("  Key features: " .. table.concat(key_features, ", "))
    end

    print ""
  end

  -- Diagnostics summary
  local diagnostics = vim.diagnostic.get(bufnr)
  if #diagnostics > 0 then
    print "󰒡 Diagnostics Summary:"
    local counts = { ERROR = 0, WARN = 0, INFO = 0, HINT = 0 }

    for _, diagnostic in ipairs(diagnostics) do
      local severity = vim.diagnostic.severity[diagnostic.severity]
      counts[severity] = counts[severity] + 1
    end

    print("  󰅚 Errors: " .. counts.ERROR)
    print("  󰀪 Warnings: " .. counts.WARN)
    print("  󰋽 Info: " .. counts.INFO)
    print("  󰌶 Hints: " .. counts.HINT)
    print("  Total: " .. #diagnostics)
  else
    print "󰄬 No diagnostics"
  end

  print ""
  print "Use :LspLog to view detailed logs"
  print "Use :LspCapabilities for full capability list"
end

-- Create command
vim.api.nvim_create_user_command("LspInfo", lsp_info, { desc = "Show comprehensive LSP information" })

local function lsp_status_short()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients { bufnr = bufnr }

  if #clients == 0 then
    return "" -- Return empty string when no LSP
  end

  local names = {}
  for _, client in ipairs(clients) do
    table.insert(names, client.name)
  end

  return "󰒋 " .. table.concat(names, ",")
end

local function git_branch()
  local ok, handle = pcall(io.popen, "git branch --show-current 2>/dev/null")
  if not ok or not handle then
    return ""
  end
  local branch = handle:read "*a"
  handle:close()
  if branch and branch ~= "" then
    branch = branch:gsub("\n", "")
    return " 󰊢 " .. branch
  end
  return ""
end

local function formatter_status()
  local ok, conform = pcall(require, "conform")
  if not ok then
    return ""
  end

  local formatters = conform.list_formatters_to_run(0)
  if #formatters == 0 then
    return ""
  end

  local formatter_names = {}
  for _, formatter in ipairs(formatters) do
    table.insert(formatter_names, formatter.name)
  end

  return "󰉿 " .. table.concat(formatter_names, ",")
end

local function linter_status()
  local ok, lint = pcall(require, "lint")
  if not ok then
    return ""
  end

  local linters = lint.linters_by_ft[vim.bo.filetype] or {}
  if #linters == 0 then
    return ""
  end
  return "󰁨 " .. table.concat(linters, ",")
end
-- Safe wrapper functions for statusline
local function safe_git_branch()
  local ok, result = pcall(git_branch)
  return ok and result or ""
end

local function safe_lsp_status()
  local ok, result = pcall(lsp_status_short)
  return ok and result or ""
end

local function safe_formatter_status()
  local ok, result = pcall(formatter_status)
  return ok and result or ""
end

local function safe_linter_status()
  local ok, result = pcall(linter_status)
  return ok and result or ""
end

_G.git_branch = safe_git_branch
_G.lsp_status = safe_lsp_status
_G.formatter_status = safe_formatter_status
_G.linter_status = safe_linter_status

-- THEN set the statusline
vim.opt.statusline = table.concat({
  "%{v:lua.git_branch()}",       -- Git branch
  "%f",                          -- File name
  "%m",                          -- Modified flag
  "%r",                          -- Readonly flag
  "%=",                          -- Right align
  "%{v:lua.linter_status()}",    -- Linter status
  "%{v:lua.formatter_status()}", -- Formatter status
  "%{v:lua.lsp_status()}",       -- LSP status
  " %l:%c",                      -- Line:Column
  " %p%%",                       -- Percentage through file
}, " ")
