return {
  {
    "folke/neodev.nvim",
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "glepnir/lspsaga.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "williamboman/mason-lspconfig.nvim",
      "mason.nvim",
      {
        "elixir-tools/elixir-tools.nvim",
        version = "*",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
          "nvim-lua/plenary.nvim",
        },
      },
    },
    config = function()
      local cmp_lsp = require("cmp_nvim_lsp")
      local elixir = require("elixir")
      local lspconfig = require("lspconfig")
      local mason_lspconfig = require("mason-lspconfig")

      mason_lspconfig.setup({
        ensure_installed = {
          "cssls",
          "gopls",
          "graphql",
          "html",
          "jsonls",
          "lua_ls",
          "pyright",
          "rust_analyzer",
          "tailwindcss",
          "tsserver",
          "yamlls",
          "zls",
        },
        automatic_installation = true,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

          vim.api.nvim_create_user_command("Format", function()
            vim.lsp.buf.format({ async = true })
          end, {})

          require("config.keymaps").lsp_mappings()
          require("config.keymaps").lsp_diagnostic_mappings()
        end,
      })

      local format_on_save_group = vim.api.nvim_create_augroup("formatOnSave", {})
      local on_attach = function(client, bufnr)
        if client.config.name == "yamlls" then
          vim.lsp.buf_detach_client(bufnr, client.id)
        end

        if client.supports_method("textDocument/formatting") then
          vim.api.nvim_clear_autocmds({
            group = format_on_save_group,
            buffer = bufnr,
          })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = format_on_save_group,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ bufnr = bufnr })
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

      -- add completion and documentation capabilities for cmp completion
      local create_capabilities = function(opts)
        local default_opts = {
          with_snippet_support = true,
        }
        opts = opts or default_opts
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities.textDocument.completion.completionItem.snippetSupport = opts.with_snippet_support
        if opts.with_snippet_support then
          capabilities.textDocument.completion.completionItem.resolveSupport = {
            properties = {
              "documentation",
              "detail",
              "additionalTextEdits",
            },
          }
        end

        return cmp_lsp.default_capabilities(capabilities)
      end
      -- inject our custom on_attach after the built in on_attach from the lspconfig
      lspconfig.util.on_setup = lspconfig.util.add_hook_after(lspconfig.util.on_setup, function(config)
        if config.on_attach then
          config.on_attach = lspconfig.util.add_hook_after(config.on_attach, on_attach)
        else
          config.on_attach = on_attach
        end

        config.capabilities = create_capabilities()
      end)

      elixir.setup({
        nextls = { enable = false },
        credo = { enable = true },
        elixirls = {
          enable = true,
          settings = require("elixir.elixirls").settings({
            dialyzerEnabled = true,
            enableTestLenses = false,
          }),
          on_attach = function(client, bufnr)
            require("config.keymaps").elixir_mappings()
            on_attach(client, bufnr)
          end,
        },
      })

      mason_lspconfig.setup_handlers({
        function(server_name)
          lspconfig[server_name].setup({})
        end,

        ["tailwindcss"] = function()
          lspconfig.tailwindcss.setup({
            root_dir = lspconfig.util.root_pattern(
              "assets/tailwind.config.js",
              "tailwind.config.js",
              "tailwind.config.ts",
              "postcss.config.js",
              "postcss.config.ts",
              "package.json",
              "node_modules"
            ),
            init_options = {
              userLanguages = {
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
          })
        end,

        -- Lua
        ["lua_ls"] = function()
          -- Make runtime files discoverable to the lua server
          local runtime_path = vim.split(package.path, ";")
          table.insert(runtime_path, "lua/?.lua")
          table.insert(runtime_path, "lua/?/init.lua")

          lspconfig.lua_ls.setup({
            settings = {
              Lua = {
                runtime = {
                  -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                  version = "LuaJIT",
                  -- Setup your lua path
                  path = runtime_path,
                },
                diagnostics = {
                  -- Get the language server to recognize the `vim` global
                  globals = { "vim" },
                  unusedLocalExclude = { "_*" },
                },
                workspace = {
                  -- Make the server aware of Neovim runtime files
                  library = vim.api.nvim_get_runtime_file("", true),
                  -- Stop prompting about 'luassert'. See https://github.com/neovim/nvim-lspconfig/issues/1700
                  checkThirdParty = false,
                },
                -- Do not send telemetry data containing a randomized but unique identifier
                telemetry = {
                  enable = false,
                },
              },
            },
          })
        end,
      })
    end,
  },
  {

    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {
      ensure_installed = {
        "black",
        "codespell",
        "eslint_d",
        "isort",
        "prettier",
        "pylint",
        "stylua",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
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
    end,
  },
  -- Formatter
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local conform = require("conform")

      conform.setup({
        formatter_by_ft = {
          ["*"] = { "codespell" },
          css = { "prettier" },
          graphql = { "prettier" },
          html = { "prettier" },
          javascript = { "prettier" },
          javascriptreact = { "prettier" },
          lua = { "stylua" },
          markdown = { "prettier" },
          python = { "isort", "black" },
          typescript = { "prettier" },
          typescriptreact = { "prettier" },
          yaml = { "prettier" },
        },
        format_on_save = {
          async = false,
          lsp_fallback = true,
          timeout_ms = 500,
        },
      })

      require("config.keymaps").formatting_mappings()
    end,
  },
  -- Linting
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        ["*"] = { "codespell" },
        elixir = { "credo" },
        javascript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        python = { "pylint" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        yaml = { "yamllint" },
      }

      local lint_augroup = vim.api.nvim_create_augroup("lint", {
        clear = true,
      })

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })

      require("config.keymaps").lint_mappings(lint)
    end,
  },
}
