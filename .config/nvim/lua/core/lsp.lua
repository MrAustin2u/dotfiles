-- Auto-discover LSP configs from lsp/*.lua files
local lsp_dir = vim.fn.stdpath "config" .. "/lsp"
local servers = {}

for name, type in vim.fs.dir(lsp_dir) do
  if type == "file" and name:sub(-4) == ".lua" then
    table.insert(servers, name:sub(1, -5))
  end
end

vim.lsp.enable(servers)

-- Disable vim.lsp.document_color (new in Nvim 0.12, enabled by default).
-- Its on_lines hook races with apply_text_edits during blink.cmp completion
-- accept and trips an assert in runtime/lua/vim/lsp/document_color.lua when a
-- client_state entry outlives its client. We don't use color highlighting.
if vim.lsp.document_color and vim.lsp.document_color.enable then
  vim.lsp.document_color.enable(false)
end

require("config.keymaps").lsp_diagnostic_mappings()

--- Sets up capability-guarded keymaps for a given client/buffer.
---@param client vim.lsp.Client
---@param bufnr integer
local function on_attach(client, bufnr)
  local function map(method, mode, lhs, rhs, desc)
    if method == nil or client:supports_method(method) then
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
    end
  end

  -- Navigation
  map("textDocument/definition", "n", "gd", function()
    Snacks.picker.lsp_definitions()
  end, "Go to Definition")

  map("textDocument/references", "n", "gr", function()
    Snacks.picker.lsp_references()
  end, "Go to References")

  map("textDocument/implementation", "n", "gI", function()
    Snacks.picker.lsp_implementations()
  end, "Go to Implementation")

  map("textDocument/typeDefinition", "n", "<leader>D", function()
    Snacks.picker.lsp_type_definitions()
  end, "Go to Type Definition")

  map("textDocument/declaration", "n", "gD", function()
    Snacks.picker.lsp_declarations()
  end, "Go to Declaration")

  -- Actions
  map("textDocument/codeAction", "n", "<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
  map("textDocument/hover", "n", "K", vim.lsp.buf.hover, "LSP Hover Doc")
  map("textDocument/rename", "n", "<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame Symbol Under Cursor")

  map("textDocument/formatting", "n", "<leader>fm", function()
    vim.lsp.buf.format { async = true }
  end, "LSP: [f]or[m]at")

  map("textDocument/inlayHint", "n", "<leader>th", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr })
  end, "LSP: [T]oggle Inlay [H]ints")

  -- nvim-navic breadcrumbs. Only the first client per buffer that
  -- supports documentSymbolProvider may attach -- navic errors out
  -- when a second client (e.g. graphql on a .tsx file already served
  -- by vtsls) tries to take over.
  if client.server_capabilities.documentSymbolProvider and not vim.b[bufnr].navic_client_id then
    local has_navic, navic = pcall(require, "nvim-navic")
    if has_navic then
      navic.attach(client, bufnr)
      vim.b[bufnr].navic_client_id = client.id
    end
  end

  -- Server-specific user commands
  if client.name == "eslint" then
    vim.api.nvim_buf_create_user_command(bufnr, "LspEslintFixAll", function()
      client:request_sync("workspace/executeCommand", {
        command = "eslint.applyAllFixes",
        arguments = {
          {
            uri = vim.uri_from_bufnr(bufnr),
            version = vim.lsp.util.buf_versions[bufnr],
          },
        },
      }, nil, bufnr)
    end, { desc = "ESLint: Fix all auto-fixable problems" })
  elseif client.name == "pyright" then
    vim.api.nvim_buf_create_user_command(bufnr, "LspPyrightOrganizeImports", function()
      -- Using client:request() directly because "pyright.organizeimports" is
      -- private (not advertised via capabilities), which client:exec_cmd()
      -- refuses to call.
      client:request("workspace/executeCommand", {
        command = "pyright.organizeimports",
        arguments = { vim.uri_from_bufnr(bufnr) },
      }, nil, bufnr)
    end, { desc = "Pyright: Organize imports" })

    vim.api.nvim_buf_create_user_command(bufnr, "LspPyrightSetPythonPath", function(command)
      local path = command.args
      if client.settings then
        local existing = client.settings.python --[[@as table?]]
          or {}
        client.settings.python = vim.tbl_deep_extend("force", existing, { pythonPath = path })
      else
        client.config.settings =
          vim.tbl_deep_extend("force", client.config.settings, { python = { pythonPath = path } })
      end
      client:notify("workspace/didChangeConfiguration", { settings = nil })
    end, {
      desc = "Pyright: Reconfigure with the provided python path",
      nargs = 1,
      complete = "file",
    })
  end
end

local lsp_group = vim.api.nvim_create_augroup("UserLspConfig", {})

vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_group,
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    on_attach(client, ev.buf)
  end,
})

-- Re-run on_attach when capabilities are dynamically registered (e.g. eslint)
-- so late-arriving keymaps/handlers get wired up. Iterate every buffer the
-- client is actually attached to instead of `nvim_get_current_buf()`, which
-- can be wrong if the user switched buffers while the server was initialising.
local register_capability = vim.lsp.handlers["client/registerCapability"]

---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if client then
    for bufnr in pairs(client.attached_buffers) do
      on_attach(client, bufnr)
    end
  end
  return register_capability(err, res, ctx)
end

-- LSP servers are managed by mise
-- Use `mise ls` to check which LSPs are available

vim.diagnostic.config {
  signs = {
    -- Diagnostic sign glyphs. Matches LazyVim's defaults and requires a Nerd
    -- Font (see https://www.nerdfonts.com) for the glyphs to render.
    text = {
      [vim.diagnostic.severity.ERROR] = " ", -- nf-fa-times_circle
      [vim.diagnostic.severity.WARN] = " ", -- nf-fa-exclamation_triangle
      [vim.diagnostic.severity.INFO] = " ", -- nf-fa-info_circle
      [vim.diagnostic.severity.HINT] = " ", -- nf-fa-lightbulb_o
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
