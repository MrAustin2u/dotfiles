return {
  {
    "b0o/SchemaStore.nvim",
    lazy = true,
    version = false, -- last release is way too old
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      {
        "williamboman/mason.nvim",
        cmd = "Mason",
        keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
        build = ":MasonUpdate",
        opts = {
          ensure_installed = {
            "biome",
            "black",
            "codespell",
            "delve",
            "eslint_d",
            "gofumpt",
            "goimports",
            "gomodifytags",
            "impl",
            "isort",
            "prettier",
            "pylint",
            "stylua",
            "tflint"
          },
          ui = {
            border = "single",
            width = 0.7,
            height = 0.8,
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
      {
        "elixir-tools/elixir-tools.nvim",
        version = "*",
        dev = false,
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "nvim-lua/plenary.nvim" },
      },
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
          border = 'rounded',
        },
      },
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "biome",
          "dockerls",
          "grammarly",
          "graphql",
          "lua_ls",
          "rust_analyzer",
          "sqlls",
          "terraformls",
          "tsserver",
          "yamlls",
          "pyright",
          "zls",
        },
        automatic_installlation = true,
      })

      local lspconfig = require('lspconfig')
      local format_on_save_group = vim.api.nvim_create_augroup('formatOnSave', {})
      local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          -- enable completion triggered by <c-x><c-o>
          vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

          -- diagnostics
          require("config.keymaps").lsp_diagnostic_mappings()
          for name, icon in pairs(require('utils').icons.diagnostics) do
            name = 'DiagnosticSign' .. name
            vim.fn.sign_define(name, { text = icon, texthl = name, numhl = '' })
          end

          -- lsp keymaps
          require("config.keymaps").lsp_mappings()
        end,
      })

      local on_attach = function(client, bufnr)
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

        -- PYTHON
        if client.name == "ruff_lsp" then
          -- Disable hover in favor of Pyright
          client.server_capabilities.hoverProvider = false
        end

        -- GO
        -- workaround for gopls not supporting semanticTokensProvider
        -- https://github.com/golang/go/issues/54531#issuecomment-1464982242
        if client.name == "gopls" then
          if not client.server_capabilities.semanticTokensProvider then
            local semantic = client.config.capabilities.textDocument.semanticTokens
            client.server_capabilities.semanticTokensProvider = {
              full = true,
              legend = {
                tokenTypes = semantic.tokenTypes,
                tokenModifiers = semantic.tokenModifiers,
              },
              range = true,
            }
          end
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

      require("mason-lspconfig").setup_handlers {
        ['lua_ls'] = function()
          opts.settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              runtime = { version = "LuaJIT" },
              completion = {
                workspaceWord = true,
                callSnippet = "Both",
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
              doc = {
                privateName = { "^_" },
              },
              type = {
                castNumberToInteger = true,
              },
              diagnostics = {
                globals = { "vim" },
                disable = { "incomplete-signature-doc", "trailing-space" },
                groupSeverity = {
                  strong = "Warning",
                  strict = "Warning",
                },
                groupFileStatus = {
                  ["ambiguity"] = "Opened",
                  ["await"] = "Opened",
                  ["codestyle"] = "None",
                  ["duplicate"] = "Opened",
                  ["global"] = "Opened",
                  ["luadoc"] = "Opened",
                  ["redefined"] = "Opened",
                  ["strict"] = "Opened",
                  ["strong"] = "Opened",
                  ["type-check"] = "Opened",
                  ["unbalanced"] = "Opened",
                  ["unused"] = "Opened",
                },
                unusedLocalExclude = { "_*" },
              },
              telemetry = {
                enable = false,
              },
              format = {
                enable = true,
                defaultConfig = {
                  indent_style = "space",
                  indent_size = "2",
                  continuation_indent_size = "2",
                },
              },
            },
          }

          lspconfig.lua_ls.setup(opts)
        end,

        ['tsserver'] = function()
          opts.keys = {
            {
              "<leader>co",
              function()
                vim.lsp.buf.code_action({
                  apply = true,
                  context = {
                    only = { "source.organizeImports.ts" },
                    diagnostics = {},
                  },
                })
              end,
              desc = "Organize Imports",
            },
          }
          opts.settings = {
            typescript = {
              format = {
                indentSize = vim.o.shiftwidth,
                convertTabsToSpaces = vim.o.expandtab,
                tabSize = vim.o.tabstop,
              },
            },
            javascript = {
              format = {
                indentSize = vim.o.shiftwidth,
                convertTabsToSpaces = vim.o.expandtab,
                tabSize = vim.o.tabstop,
              },
            },
            completions = {
              completeFunctionCalls = true,
            },
          }

          lspconfig.tsserver.setup(opts)
        end,

        ['gopls'] = function()
          opts.settings = {
            gopls = {
              gofumpt = true,
              codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              analyses = {
                fieldalignment = true,
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
              },
              usePlaceholders = true,
              completeUnimported = true,
              staticcheck = true,
              directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
              semanticTokens = true,
            },
          }

          lspconfig.gopls.setup(opts)
        end,

        ['pyright'] = function()
          lspconfig.pyright.setup(opts)
        end,

        ['tailwindcss'] = function()
          lspconfig.tailwindcss.setup(opts)
        end,

        ['terraformls'] = function()
          lspconfig.terraformls.setup(opts)
        end,

        ['jsonls'] = function()
          opts.on_new_config = function(new_config)
            new_config.settings.json.schemas = new_config.settings.json.schemas or {}
            vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
          end

          opts.settings = {
            json = {
              format = {
                enable = true,
              },
              validate = { enable = true },
            },
          }
          lspconfig.jsonls.setup(opts)
        end,

        ["yamlls"] = function()
          opts.capabilities = {
            textDocument = {
              foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true,
              },
            },
          }

          opts.on_new_config = function(new_config)
            new_config.settings.yaml.schemas = vim.tbl_deep_extend(
              "force",
              new_config.settings.yaml.schemas or {},
              require("schemastore").yaml.schemas()
            )
          end
          opts.settings = {
            redhat = { telemetry = { enabled = false } },
            yaml = {
              keyOrdering = false,
              format = {
                enable = true,
              },
              validate = true,
              schemaStore = {
                -- Must disable built-in schemaStore support to use
                -- schemas from SchemaStore.nvim plugin
                enable = false,
                -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                url = "",
              },
            }
          }

          lspconfig.yamlls.setup(opts)
        end
      }

      local elixir = require("elixir")

      elixir.setup({
        nextls = { enable = false },
        credo = { enable = true },
        elixirls = {
          on_attach = function(client, bufnr)
            on_attach(client, bufnr)
            require("config.keymaps").elixir_mappings()
          end,
          tag = "v0.16.0",
        },
      })
    end
  },
}
