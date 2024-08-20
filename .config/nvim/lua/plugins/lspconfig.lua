return {
  "neovim/nvim-lspconfig",
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
  },
  config = function()
    -- configure LSP capabilities
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    if pcall(require, "cmp_nvim_lsp") then
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
    end

    local on_attach = function(client, bufnr)
      if client.supports_method "textDocument/formatting" then
        local format_on_save_group = vim.api.nvim_create_augroup("formatOnSave", {})
        vim.api.nvim_clear_autocmds { group = format_on_save_group, buffer = bufnr }
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = format_on_save_group,
          buffer = bufnr,
          callback = function(_args)
            require("conform").format {
              bufnr = bufnr,
              lsp_fallback = true,
              quiet = true,
            }
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

    local setup_diagnostics = function()
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
    end

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)

        setup_diagnostics()
        require("config.keymaps").lsp_mappings(event.buf)

        vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"

        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          require("config.keymaps").lsp_inlay_hints_mappings(event.buf)
        end
      end,
    })

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
      "lexical",
      "lua-language-server",
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
          capabilities = capabilities,
          on_attach = on_attach,
        }
        require("lspconfig")[server_name].setup(server_opts)
      end,

      -- elixir
      ["lexical"] = function()
        local overrides = require("plugins.lspsettings.lexical").setup {
          lspconfig = lspconfig,
          root_pattern = root_pattern,
        }
        lspconfig.lexical.setup(overrides)
      end,

      -- go
      ["gopls"] = function()
        local overrides = require "plugins.lspsettings.gopls"
        lspconfig.gopls.setup(overrides)
      end,

      -- json
      ["jsonls"] = function()
        local overrides = require "plugins.lspsettings.jsonls"
        lspconfig.jsonls.setup(overrides)
      end,

      -- lua
      ["lua_ls"] = function()
        local overrides = require "plugins.lspsettings.lua_ls"
        lspconfig.lua_ls.setup(overrides)
      end,

      -- tailwindcss
      ["tailwindcss"] = function()
        local overrides = require("plugins.lspsettings.tailwindcss").setup { root_pattern = root_pattern }
        lspconfig.tailwindcss.setup(overrides)
      end,

      -- typescript
      ["vtsls"] = function()
        local overrides = require "plugins.lspsettings.vtsls"
        lspconfig.vtsls.setup(overrides)
      end,

      -- yaml
      ["yamlls"] = function()
        local overrides = require "plugins.lspsettings.yamlls"
        lspconfig.yamlls.setup(overrides)
      end,
    }
  end,
}
