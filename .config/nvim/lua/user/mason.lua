local M = {
  "williamboman/mason.nvim",
  cmd = "Mason",
  keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
  build = ":MasonUpdate",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
    "folke/neodev.nvim",
    "hrsh7th/cmp-nvim-lsp",
    { "b0o/schemastore.nvim", lazy = true },
  },
  opts = {
    ensure_installed = {
      -- Formatters
      "black",
      "stylua",
      "prettier",
      "isort",
      -- Linters
      "codespell",
      "eslint_d",
      "tflint",
      "yamllint",
      "commitlint",
      -- LSPs
      "bash-language-server",
      "css-lsp",
      "eslint-lsp",
      "go-debug-adapter",
      "goimports",
      "golangci-lint",
      "golangci-lint-langserver",
      "gomodifytags",
      "gopls",
      "html-lsp",
      "json-lsp",
      "lexical",
      "rust-analyzer",
      "sqlls",
      "tailwindcss-language-server",
      "terraform-ls",
      "typescript-language-server",
      "vim-language-server",
      "yaml-language-server"
    },
    ui = {
      border = "single",
      width = 0.7,
      height = 0.8,
    },
  },
}

function M.config(_, mason_opts)
  require("mason").setup(mason_opts)
  local lspconfig = require('lspconfig')
  local mason_lspconfig = require('mason-lspconfig')

  local mr = require("mason-registry")
  local function ensure_installed()
    for _, tool in ipairs(mason_opts.ensure_installed) do
      local p = mr.get_package(tool)
      if not p:is_installed() then
        p:install()
      end
    end
  end

  if mr.refresh then
    mr.refresh(ensure_installed)
  else
    ensure_installed()
  end

  -- inject our custom on_attach after the built in on_attach from the lspconfig
  lspconfig.util.on_setup = lspconfig.util.add_hook_after(lspconfig.util.on_setup, function(config)
    if config.on_attach then
      config.on_attach = lspconfig.util.add_hook_after(config.on_attach, M.on_attach)
    else
      config.on_attach = require("user.lsp").on_attach
    end

    config.capabilities = require("user.lsp").common_capabilities()
  end)

  mason_lspconfig.setup()
  mason_lspconfig.setup_handlers({
    function(server_name)
      lspconfig[server_name].setup {}
    end,

    -- JSON
    ['jsonls'] = function()
      local overrides = require("user.lspsettings.jsonls")
      lspconfig.jsonls.setup(overrides)
    end,

    -- GO
    ['gopls'] = function()
      local overrides = require("user.lspsettings.gopls")
      lspconfig.gopls.setup(overrides)
    end,

    -- Elixir
    ['lexical'] = function()
      lspconfig.lexical.setup({
        cmd = { "/Users/aaustin/.local/share/nvim/mason/bin/lexical", "server" },
        root_dir = lspconfig.util.root_pattern { "mix.exs" },
      }
      )
    end,

    -- Lua
    ['lua_ls'] = function()
      local overrides = require("user.lspsettings.lua_ls")
      require("neodev").setup()
      lspconfig.lua_ls.setup(overrides)
    end,

    -- Typescript
    -- ['tsserver'] = function()
    --   local overrides = require("user.lspsettings.tsserver")
    --   lspconfig.tsserver.setup(overrides)
    -- end,

    -- YAML
    ['yamlls'] = function()
      local overrides = require("user.lspsettings.yamlls")
      lspconfig.yamlls.setup(overrides)
    end,
  })
end

return M
