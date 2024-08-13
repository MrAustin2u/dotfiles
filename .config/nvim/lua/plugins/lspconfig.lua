return {
  "williamboman/mason.nvim",
  keys = function()
    return {
      { "<leader>lp", "<cmd>LspRestart<CR>", desc = "Restart LSP" },
      { "<leader>li", "<cmd>LspInfo<CR>", desc = "LSP Info" },
    }
  end,
  build = ":MasonUpdate",
  cmd = { "Mason", "MasonUpdate", "MasonUpdateAll" },
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
    "stevearc/conform.nvim",
    "Zeioth/mason-extra-cmds",
    "glepnir/lspsaga.nvim",
    "hrsh7th/nvim-cmp",
    "j-hui/fidget.nvim",
    "folke/neodev.nvim",
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
    local conform = require "conform"
    local lspconfig = require "lspconfig"
    local mason = require "mason"
    local mason_lspconfig = require "mason-lspconfig"
    local mr = require "mason-registry"
    local root_pattern = lspconfig.util.root_pattern

    require("neodev").setup {}

    -- setup Mason
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
      "lexical",
      "lua-language-server",
      "prosemd-lsp",
      "python-lsp-server",
      "rust-analyzer",
      "sqlls",
      "tailwindcss-language-server",
      "terraform-ls",
      "typescript-language-server",
      "vim-language-server",
      "vtsls",
      "yaml-language-server",
      "zls",
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

    -- configure LSP capabilities
    local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

    local on_attach = function(client, bufnr)
      if client.supports_method "textDocument/formatting" then
        local format_on_save_group = vim.api.nvim_create_augroup("formatOnSave", {})

        vim.api.nvim_clear_autocmds { group = format_on_save_group, buffer = bufnr }
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = format_on_save_group,
          buffer = bufnr,
          callback = function(args)
            conform.format { bufnr = args.buf }
          end,
        })
      end

      if client.server_capabilities.code_lens then
        vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
          buffer = bufnr,
          callback = vim.lsp.codelens.refresh,
        })
        vim.lsp.codelens.refresh()
      end
    end

    local opts = {
      capabilities = capabilities,
      on_attach = on_attach,
    }

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

        for name, icon in pairs(require("config.icons").diagnostics) do
          name = "DiagnosticSign" .. name
          vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
        end

        local diagnostic_config = {
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
        }

        vim.diagnostic.config(diagnostic_config)

        require("config.keymaps").lsp_diagnostic_mappings()
        require("config.keymaps").lsp_mappings()
      end,
    })

    -- manual gleam(elixir) lspconfig
    lspconfig.gleam.setup(opts)

    -- configure LSPs
    mason_lspconfig.setup {}
    mason_lspconfig.setup_handlers {
      function(server_name)
        lspconfig[server_name].setup {}
      end,

      ["tailwindcss"] = function()
        lspconfig.tailwindcss.setup {
          root_dir = root_pattern(
            "assets/tailwind.config.js",
            "tailwind.config.js",
            "tailwind.config.ts",
            "postcss.config.js",
            "postcss.config.ts",
            "package.json",
            "node_modules"
          ),
          init_options = {
            languages = {
              elixir = "phoenix-heex",
              eruby = "erb",
              heex = "phoenix-heex",
              svelte = "html",
            },
          },
          handlers = {
            ["tailwindcss/getConfiguration"] = function(_, _, params, _, bufnr, _)
              vim.lsp.buf_notify(bufnr, "tailwindcss/getConfigurationResponse", { _id = params._id })
            end,
          },
          settings = {
            includeLanguages = {
              typescript = "javascript",
              typescriptreact = "javascript",
              ["html-eex"] = "html",
              ["phoenix-heex"] = "html",
              heex = "html",
              eelixir = "html",
              elm = "html",
              erb = "html",
              svelte = "html",
            },
            tailwindCSS = {
              lint = {
                cssConflict = "warning",
                invalidApply = "error",
                invalidConfigPath = "error",
                invalidScreen = "error",
                invalidTailwindDirective = "error",
                invalidVariant = "error",
                recommendedVariantOrder = "warning",
              },
              experimental = {
                classRegex = {
                  [[class= "([^"]*)]],
                  [[class: "([^"]*)]],
                  '~H""".*class="([^"]*)".*"""',
                },
              },
              validate = true,
            },
          },
          filetypes = {
            "css",
            "scss",
            "sass",
            "html",
            "heex",
            "elixir",
            "eruby",
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "svelte",
          },
        }
      end,

      -- JSON
      ["jsonls"] = function()
        local overrides = require "plugins.lspsettings.jsonls"
        lspconfig.jsonls.setup(overrides)
      end,

      -- YAML
      ["yamlls"] = function()
        local overrides = require("plugins.lspsettings.yamlls").setup()
        lspconfig.yamlls.setup(overrides)
      end,

      -- Lua
      ["lua_ls"] = function()
        local overrides = require "plugins.lspsettings.lua_ls"
        lspconfig.lua_ls.setup(overrides)
      end,

      -- Elixir
      ["lexical"] = function()
        local overrides = require "plugins.lspsettings.lexical"
        lspconfig.lexical.setup(overrides)
      end,

      -- GO
      ["gopls"] = function()
        local overrides = require "plugins.lspsettings.gopls"
        lspconfig.gopls.setup(overrides)
      end,

      -- GO
      ["vtsls"] = function()
        local overrides = require "plugins.lspsettings.vtsls"
        lspconfig.vtsls.setup(overrides)
      end,
    }
  end,
}
