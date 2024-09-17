local LSPHELPERS = require "plugins.lsp.helpers"

return {
  "neovim/nvim-lspconfig",
  keys = function()
    return {
      { "<leader>lr", "<cmd>LspRestart<CR>", desc = "Restart LSP" },
      { "<leader>li", "<cmd>LspInfo<CR>", desc = "LSP Info" },
    }
  end,
  build = ":MasonUpdate",
  cmd = { "Mason", "MasonUpdate", "MasonUpdateAll" },
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim",
    "Zeioth/mason-extra-cmds",
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "stevearc/conform.nvim",
    "glepnir/lspsaga.nvim",
    "hrsh7th/cmp-nvim-lsp",
    "j-hui/fidget.nvim",
    "folke/lazydev.nvim",
    { "b0o/schemastore.nvim", lazy = true },
    {
      "elixir-tools/elixir-tools.nvim",
      version = "*",
      ft = { "elixir", "heex", "eelixir" },
      dependencies = {
        "nvim-lua/plenary.nvim",
      },
    },
  },
  config = function()
    LSPHELPERS.lsp_attach()

    -- mason-lspconfig
    local lspconfig = require "lspconfig"
    local mason = require "mason"
    local mason_lspconfig = require "mason-lspconfig"
    local mr = require "mason-registry"
    local root_pattern = lspconfig.util.root_pattern

    local package_list = {
      -- Formatters and Linters
      "black",
      "codespell",
      "prettierd",
      "shfmt",
      "stylua",
      "yamllint",
      "actionlint",
      "ansible-lint",

      -- LSPs
      "bash-language-server",
      "clang-format",
      "css-lsp",
      "dockerfile-language-server",
      "eslint-lsp",
      "goimports",
      "golangci-lint",
      "golangci-lint-langserver",
      "gomodifytags",
      "gopls",
      "html-lsp",
      "json-lsp",
      "lua-language-server",
      -- "nextls",
      "prosemd-lsp",
      "python-lsp-server",
      "rust-analyzer",
      "sqlls",
      "tailwindcss-language-server",
      "terraform-ls",
      "vim-language-server",
      "vtsls",
      "yaml-language-server",
      "zls",
      "lexical",
    }

    mason.setup {}
    local function ensure_installed()
      for _, tool in ipairs(package_list) do
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

    mason_lspconfig.setup {}
    mason_lspconfig.setup_handlers {
      function(server_name)
        local server_opts = {
          capabilities = LSPHELPERS.create_capabilities(),
          on_attach = LSPHELPERS.on_attach,
        }
        require("lspconfig")[server_name].setup(server_opts)
      end,

      -- elixir
      ["lexical"] = function()
        local overrides = require("plugins.lsp.configs.lexical").setup {
          lspconfig = lspconfig,
          root_pattern = root_pattern,
        }
        lspconfig.lexical.setup(overrides)
      end,

      -- ["nextls"] = function()
      --   local elixirls = require "elixir.elixirls"
      --   local overrides = require("plugins.lsp.configs.nextls").setup {
      --     elixirls = elixirls,
      --   }
      --   lspconfig.nextls.setup(overrides)
      -- end,

      -- go
      ["gopls"] = function()
        local overrides = require "plugins.lsp.configs.gopls"
        lspconfig.gopls.setup(overrides)
      end,

      -- json
      ["jsonls"] = function()
        local overrides = require "plugins.lsp.configs.jsonls"
        lspconfig.jsonls.setup(overrides)
      end,

      -- lua
      ["lua_ls"] = function()
        local overrides = require "plugins.lsp.configs.lua_ls"
        lspconfig.lua_ls.setup(overrides)
      end,

      -- tailwindcss
      ["tailwindcss"] = function()
        local overrides = require("plugins.lsp.configs.tailwindcss").setup { root_pattern = root_pattern }
        lspconfig.tailwindcss.setup(overrides)
      end,

      -- typescript
      ["vtsls"] = function()
        local overrides = require "plugins.lsp.configs.vtsls"
        lspconfig.vtsls.setup(overrides)
      end,

      -- yaml
      ["yamlls"] = function()
        local overrides = require "plugins.lsp.configs.yamlls"
        lspconfig.yamlls.setup(overrides)
      end,
    }
  end,
}
