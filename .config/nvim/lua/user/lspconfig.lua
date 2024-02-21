local Utils = require("config.utils")

local M = {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    { "folke/neodev.nvim" },
  },
  opts = {
    diagnostics = {
      underline = true,
      update_in_insert = false,
      virtual_text = {
        spacing = 4,
        source = "if_many",
        prefix = "●",
      },
      severity_sort = true,
      float = {
        border = "rounded",
      },
    },
  },
}

local function lsp_keymaps(bufnr)
  local opts = { noremap = true, silent = true }
  local keymap = vim.api.nvim_buf_set_keymap
  keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
  vim.keymap.set("n", "gd", Utils.telescope("lsp_definitions"), opts)
  keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  keymap(bufnr, "n", "gI", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  vim.keymap.set("n", "gr", Utils.telescope("lsp_references"), opts)
  keymap(bufnr, "n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
  keymap(bufnr, "n", "fs", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
  keymap(bufnr, "n", "<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
  keymap(bufnr, "n", "<leader>bf", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", opts)
  keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  keymap(bufnr, "n", "<leader>li", "<cmd>LspInfo<cr>", opts)
  keymap(bufnr, "n", "<leader>lr", "<cmd>LspRestart<cr>", opts)

  if vim.lsp.inlay_hint then
    vim.keymap.set("n", "<leader>lh", function()
      vim.lsp.inlay_hint(0, nil)
    end, Utils.merge_maps(opts, { desc = "Toggle Inlay Hints" }))
  end
end

local format_on_save_group = vim.api.nvim_create_augroup("formatOnSave", {})
function M.on_attach(client, bufnr)
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_clear_autocmds({ group = format_on_save_group, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = format_on_save_group,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ bufnr = bufnr })
      end,
    })
  end

  if client.supports_method("textDocument/inlayHint") then
    vim.lsp.inlay_hint.enable(bufnr, true)
  end

  if client.server_capabilities.code_lens then
    vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
      buffer = bufnr,
      callback = vim.lsp.codelens.refresh,
    })
    vim.lsp.codelens.refresh()
  end
end

local function common_capabilities()
  local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  return capabilities
end

local function lsp_diagnostics()
  local icons = require("config.icons")
  local default_diagnostic_config = {
    signs = {
      active = true,
      values = {
        { name = "DiagnosticSignError", text = icons.diagnostics.Error },
        { name = "DiagnosticSignWarn",  text = icons.diagnostics.Warning },
        { name = "DiagnosticSignHint",  text = icons.diagnostics.Hint },
        { name = "DiagnosticSignInfo",  text = icons.diagnostics.Information },
      },
    },
    virtual_text = false,
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    float = {
      focusable = true,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  }

  vim.diagnostic.config(default_diagnostic_config)

  for _, sign in ipairs(vim.tbl_get(vim.diagnostic.config(), "signs", "values") or {}) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
  end
end

local function lsp_diagnostic_mappings()
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

function M.config()
  local lspconfig = require("lspconfig")

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
      -- enable completion triggered by <c-x><c-o>
      vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

      -- diagnostics
      lsp_diagnostic_mappings()
      lsp_diagnostics()
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
      require("lspconfig.ui.windows").default_options.border = "rounded"

      -- lsp keymaps
      lsp_keymaps(ev.buf)
    end,
  })

  local servers = {
    "bashls",
    "cssls",
    "dockerls",
    "elixirls",
    "eslint",
    "html",
    "pyright",
    "graphql",
    "jsonls",
    "lua_ls",
    "pyright",
    "rust_analyzer",
    "sqlls",
    "terraformls",
    "tsserver",
    "yamlls",
  }

  for _, server in pairs(servers) do
    local opts = {
      on_attach = M.on_attach,
      capabilities = common_capabilities(),
    }

    local require_ok, settings = pcall(require, "user.lspsettings." .. server)
    if require_ok then
      opts = vim.tbl_deep_extend("force", settings, opts)
    end

    if server == "elixirls" then
      opts.root_dir = function(fname)
        local path = lspconfig.util.path
        local child_or_root_path = lspconfig.util.root_pattern({ "mix.exs", ".git" })(fname)
        local maybe_umbrella_path = lspconfig.util.root_pattern({ "mix.exs" })(
          vim.loop.fs_realpath(path.join({ child_or_root_path, ".." }))
        )

        local has_ancestral_mix_exs_path = vim.startswith(child_or_root_path,
          path.join({ maybe_umbrella_path, "apps" }))
        if maybe_umbrella_path and not has_ancestral_mix_exs_path then
          maybe_umbrella_path = ""
        end

        return Utils.get_data(maybe_umbrella_path) or child_or_root_path or vim.loop.os_homedir()
      end
    end

    if server == "lua_ls" then
      require("neodev").setup({})
    end

    if server == "yamlls" then
      local schemastore_avail, schemastore = pcall(require, "schemastore")
      if schemastore_avail then opts.settings = { yaml = { schemas = schemastore.yaml.schemas() } } end
    end

    if server == "jsonls" then -- by default add json schemas
      local schemastore_avail, schemastore = pcall(require, "schemastore")
      if schemastore_avail then
        opts.settings = { json = { schemas = schemastore.json.schemas(), validate = { enable = true } } }
      end
    end

    lspconfig[server].setup(opts)
  end
end

return M
