return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "mason-org/mason.nvim",
    "mason-org/mason-lspconfig.nvim",
    "jose-elias-alvarez/nvim-lsp-ts-utils",
    "saghen/blink.cmp",
    -- required for jsonls and yamlls
    { "b0o/schemastore.nvim", lazy = true },
    {
      "SmiteshP/nvim-navic",
      dependencies = { "neovim/nvim-lspconfig" },
      opts = {
        highlight = true,
      },
      init = function()
        vim.g.navic_silence = true
      end,
    },
  },
  config = function()
    local mason = require "mason"
    local mr = require "mason-registry"
    local mason_lspconfig = require "mason-lspconfig"
    local navic = require "nvim-navic"

    local mason_ensure_installed = {
      "prettier",
      "prettierd",
      "eslint_d",
      "stylua",
    }

    mason.setup()
    mr:on("package:install:success", function()
      vim.defer_fn(function()
        -- trigger FileType event to possibly load this newly installed LSP server
        require("lazy.core.handler.event").trigger {
          event = "FileType",
          buf = vim.api.nvim_get_current_buf(),
        }
      end, 100)
    end)

    mr.refresh(function()
      for _, tool in ipairs(mason_ensure_installed) do
        local p = mr.get_package(tool)
        if not p:is_installed() then
          p:install()
        end
      end
    end)

    mason_lspconfig.setup {
      ensure_installed = {
        "angularls",
        "ansiblels",
        "bashls",
        "biome",
        "dockerls",
        "erlangls",
        "eslint",
        "grammarly",
        "graphql",
        "html",
        "lemminx",
        "rust_analyzer",
        "sqlls",
        "tailwindcss",
        "taplo",
        "terraformls",
        "typos_lsp",
        "vimls",
        "zls",
      },
      automatic_enable = true,
    }

    local capabilities = function()
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        require("blink.cmp").get_lsp_capabilities() or {}
      )

      return capabilities
    end

    local on_attach = function(client, bufnr)
      local client_name = client.config.name
      local ft = vim.bo.filetype

      if client.supports_method "textDocument/formatting" then
        local format_on_save_group = vim.api.nvim_create_augroup("formatOnSave", {})

        vim.api.nvim_clear_autocmds { group = format_on_save_group, buffer = bufnr }
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = format_on_save_group,
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format { bufnr = bufnr }
          end,
        })
      end

      if vim.fn.has "nvim-0.10" == 1 then
        -- inlay hints
        aa.lsp.on_supports_method("textDocument/inlayHint", function(client, buffer)
          if
              vim.api.nvim_buf_is_valid(buffer)
              and vim.bo[buffer].buftype == ""
              and not vim.tbl_contains({ "vue" }, vim.bo[buffer].filetype)
          then
            vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
          end
        end)

        -- code lens
        aa.lsp.on_supports_method("textDocument/codeLens", function(client, buffer)
          vim.lsp.codelens.refresh()
          vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
            buffer = buffer,
            callback = vim.lsp.codelens.refresh,
          })
        end)
      end

      -- /BEGIN: Helm file support
      if client_name == "yamlls" and ft == "helm" then
        vim.lsp.stop_client(client.id)
        vim.lsp.buf_detach_client(bufnr, client.id)
      end

      if vim.bo[bufnr].buftype ~= "" or ft == "helm" then
        vim.diagnostic.enable(false, bufnr)
        -- remove existing diagnostic messages that appear about a second after load
        -- (in the status bar). They do end up coming back though after awhile, not
        -- sure why
        vim.defer_fn(function()
          vim.diagnostic.reset(nil, bufnr)
        end, 2000)
      end
      -- /END: Helm file support

      -- support for lsp based breadcrumbs
      if client.server_capabilities.documentSymbolProvider then
        navic.attach(client, bufnr)
      end
    end

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
        require("config.keymaps").lsp_diagnostic_mappings()
        require("config.keymaps").lsp_mappings()
      end,
    })

    local opts = {
      capabilities = capabilities(),
      on_attach = on_attach,
    }

    -- lua
    opts.settings = {
      Lua = {
        workspace = {
          checkThirdParty = false,
        },
        codeLens = {
          enable = true,
        },
        completion = {
          callSnippet = "Replace",
        },
        doc = {
          privateName = { "^_" },
        },
        hint = {
          enable = true,
          setType = false,
          paramType = true,
          paramName = "Disable",
          semicolon = "Disable",
          arrayIndex = "Disable",
        },
        runtime = {
          version = "LuaJIT",
        },
        diagnostics = {
          globals = { "vim", "hs" },
        },
      },
    }
    vim.lsp.config("lua_ls", opts)
    vim.lsp.enable "lua_ls"

    -- elixir
    vim.lsp.config("lexical", {
      filetypes = { "elixir", "eelixir", "heex", "surface", "livebook" },
      single_file_support = true,
      dialyzer_enabled = true,
    })
    vim.lsp.enable "lexical"

    -- yaml
    vim.lsp.config("yamlls", {
      capabilities = {
        textDocument = {
          foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true,
          },
        },
      },
      on_new_config = function(new_config)
        new_config.settings.yaml.schemas =
            vim.tbl_deep_extend("force", new_config.settings.yaml.schemas or {}, require("schemastore").yaml.schemas())
      end,
      settings = {
        redhat = { telemetry = { enabled = false } },
        yaml = {
          keyOrdering = false,
          format = {
            enable = true,
          },
          validate = true,
          schemaStore = {
            enable = false,
            url = "",
          },
        },
      },
    })
    vim.lsp.enable "yamlls"

    -- javascript
    vim.lsp.config("vtsls", {
      filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
      },
      settings = {
        complete_function_calls = true,
        vtsls = {
          enableMoveToFileCodeAction = true,
          autoUseWorkspaceTsdk = true,
          experimental = {
            maxInlayHintLength = 30,
            completion = {
              enableServerSideFuzzyMatch = true,
            },
          },
        },
        typescript = {
          updateImportsOnFileMove = { enabled = "always" },
          suggest = {
            completeFunctionCalls = true,
          },
          inlayHints = {
            enumMemberValues = { enabled = true },
            functionLikeReturnTypes = { enabled = true },
            parameterNames = { enabled = "literals" },
            parameterTypes = { enabled = true },
            propertyDeclarationTypes = { enabled = true },
            variableTypes = { enabled = false },
          },
        },
      },
      keys = {
        {
          "gD",
          function()
            local params = vim.lsp.util.make_position_params()
            aa.lsp.execute {
              command = "typescript.goToSourceDefinition",
              arguments = { params.textDocument.uri, params.position },
              open = true,
            }
          end,
          desc = "Goto Source Definition",
        },
        {
          "gR",
          function()
            aa.lsp.execute {
              command = "typescript.findAllFileReferences",
              arguments = { vim.uri_from_bufnr(0) },
              open = true,
            }
          end,
          desc = "File References",
        },
        {
          "<leader>co",
          aa.lsp.action["source.organizeImports"],
          desc = "Organize Imports",
        },
        {
          "<leader>cM",
          aa.lsp.action["source.addMissingImports.ts"],
          desc = "Add missing imports",
        },
        {
          "<leader>cu",
          aa.lsp.action["source.removeUnused.ts"],
          desc = "Remove unused imports",
        },
        {
          "<leader>cD",
          aa.lsp.action["source.fixAll.ts"],
          desc = "Fix all diagnostics",
        },
        {
          "<leader>cV",
          function()
            aa.lsp.execute { command = "typescript.selectTypeScriptVersion" }
          end,
          desc = "Select TS workspace version",
        },
      },
    })
    vim.lsp.enable "vtsls"

    -- json
    vim.lsp.config("jsonls", {
      on_new_config = function(new_config)
        new_config.settings.json.schemas = new_config.settings.json.schemas or {}
        vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
      end,
      settings = {
        json = {
          format = {
            enable = true,
          },
          validate = { enable = true },
        },
      },
    })
    vim.lsp.enable "jsonls"

    -- go
    vim.lsp.config("gopls", {
      settings = {
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
      },
    })
    vim.lsp.enable "gopls"

    for name, icon in pairs(aa.icons.diagnostics) do
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
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = aa.icons.diagnostics.Error,
          [vim.diagnostic.severity.WARN] = aa.icons.diagnostics.Warn,
          [vim.diagnostic.severity.HINT] = aa.icons.diagnostics.Hint,
          [vim.diagnostic.severity.INFO] = aa.icons.diagnostics.Info,
        },
      },
      float = {
        border = "rounded",
      },
    }

    vim.diagnostic.config(diagnostic_config)
  end,
}
