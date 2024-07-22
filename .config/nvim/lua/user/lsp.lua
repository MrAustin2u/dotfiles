local M = {
  "neovim/nvim-lspconfig",
  dependencies = {
    "folke/neodev.nvim",
    "hrsh7th/cmp-nvim-lsp",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",

    { "https://git.sr.ht/~whynothugo/lsp_lines.nvim" },

    -- Autoformatting
    "stevearc/conform.nvim",

    -- Schema information
    "b0o/SchemaStore.nvim",
  },
}

M.capabilities = function()
  local capabilities = nil
  if pcall(require, "cmp_nvim_lsp") then
    capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
    capabilities.textDocument.completion.completionItem.snippetSupport = true
  end

  return capabilities
end

function M.config()
  require("neodev").setup {}
  local lspconfig = require "lspconfig"

  local capabilities = nil
  if pcall(require, "cmp_nvim_lsp") then
    capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
    capabilities.textDocument.completion.completionItem.snippetSupport = true
  end

  local servers = {
    bashls = true,
    biome = true,
    cssls = true,
    html = true,
    pyright = true,
    rust_analyzer = true,
    sqlls = true,
    terraformls = true,

    gopls = require "user.lspsettings.gopls",
    jsonls = require "user.lspsettings.jsonls",
    lexical = require("user.lspsettings.lexical").config(lspconfig),
    lua_ls = require "user.lspsettings.lua_ls",
    tsserver = require "user.lspsettings.tsserver",
    yamlls = require "user.lspsettings.yamlls",
  }

  local servers_to_install = vim.tbl_filter(function(key)
    local t = servers[key]
    if type(t) == "table" then
      return not t.manual_install
    else
      return t
    end
  end, vim.tbl_keys(servers))

  require("mason").setup()
  local ensure_installed = {
    "commitlint",
    "lua_ls",
    "stylua",
    "tailwindcss-language-server",
  }

  vim.list_extend(ensure_installed, servers_to_install)
  require("mason-tool-installer").setup { ensure_installed = ensure_installed }

  for name, config in pairs(servers) do
    if config == true then
      config = {}
    end
    config = vim.tbl_deep_extend("force", {}, {
      capabilities = M.capabilities(),
    }, config)

    lspconfig[name].setup(config)
  end

  local disable_semantic_tokens = {
    lua = true,
  }

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local bufnr = args.buf
      local client = assert(vim.lsp.get_client_by_id(args.data.client_id), "must have valid client")

      local settings = servers[client.name]
      if type(settings) ~= "table" then
        settings = {}
      end

      require("config.keymaps").lsp_diagnostic_mappings()
      require("config.keymaps").lsp_mappings()

      local filetype = vim.bo[bufnr].filetype
      if disable_semantic_tokens[filetype] then
        client.server_capabilities.semanticTokensProvider = nil
      end
    end,
  })

  -- Autoformatting Setup
  require("conform").setup {
    formatters_by_ft = {
      lua = { "stylua" },
    },
  }

  require("lsp_lines").setup()

  vim.diagnostic.config { virtual_text = false }

  vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function(args)
      require("conform").format {
        bufnr = args.buf,
        lsp_fallback = true,
        quiet = true,
      }
    end,
  })
end

return M
