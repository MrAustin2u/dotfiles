local ICONS = require "config.icons"
local LSPUTILS = require "config.utils.lsp"
local UTILS = require "config.utils"

return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    { "williamboman/mason-lspconfig.nvim", config = function() end },
    {
      "hrsh7th/nvim-cmp",
      version = false, -- last release is way too old
      event = "InsertEnter",
      dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
      },
    },
    {
      "saghen/blink.cmp",
      dependencies = {
        "rafamadriz/friendly-snippets",
        "onsails/lspkind.nvim",
        "giuxtaposition/blink-cmp-copilot",
      },
      version = "*",
      opts = {
        -- keymap = { preset = "default" },
        keymap = {
          ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
          ["<C-e>"] = { "hide", "fallback" },
          ["<CR>"] = { "accept", "fallback" },

          ["<Tab>"] = {
            function(cmp)
              return cmp.select_next()
            end,
            "snippet_forward",
            "fallback",
          },
          ["<S-Tab>"] = {
            function(cmp)
              return cmp.select_prev()
            end,
            "snippet_backward",
            "fallback",
          },

          ["<Up>"] = { "select_prev", "fallback" },
          ["<Down>"] = { "select_next", "fallback" },
          ["<C-p>"] = { "select_prev", "fallback" },
          ["<C-n>"] = { "select_next", "fallback" },
          ["<C-up>"] = { "scroll_documentation_up", "fallback" },
          ["<C-down>"] = { "scroll_documentation_down", "fallback" },
        },

        appearance = {
          use_nvim_cmp_as_default = true,
          nerd_font_variant = "mono",
        },

        completion = {
          accept = { auto_brackets = { enabled = true } },

          documentation = {
            auto_show = true,
            auto_show_delay_ms = 250,
            treesitter_highlighting = true,
            window = { border = "rounded" },
          },

          list = {
            selection = {
              preselect = function(ctx)
                return ctx.mode == "cmdline" and "auto_insert" or "preselect"
              end,
            },
          },

          menu = {
            border = "rounded",

            cmdline_position = function()
              if vim.g.ui_cmdline_pos ~= nil then
                local pos = vim.g.ui_cmdline_pos -- (1, 0)-indexed
                return { pos[1] - 1, pos[2] }
              end
              local height = (vim.o.cmdheight == 0) and 1 or vim.o.cmdheight
              return { vim.o.lines - height, 0 }
            end,

            draw = {
              columns = {
                { "kind_icon", "label", gap = 1 },
                { "kind" },
              },
              components = {
                kind_icon = {
                  text = function(item)
                    if item.kind == "Copilot" then
                      return "" .. " "
                    end

                    local kind = require("lspkind").symbol_map[item.kind] or ""
                    return kind .. " "
                  end,
                  highlight = "CmpItemKind",
                },
                label = {
                  text = function(item)
                    return item.label
                  end,
                  highlight = "CmpItemAbbr",
                },
                kind = {
                  text = function(item)
                    return item.kind
                  end,
                  highlight = "CmpItemKind",
                },
              },
            },
          },
        },

        signature = {
          enabled = true,
          window = { border = "rounded" },
        },

        -- opts_extend = { "sources.default" },
        sources = {
          default = {
            "buffer",
            "copilot",
            "dadbod",
            "lazydev",
            "lsp",
            "path",
            "snippets",
          },
          providers = {
            buffer = {
              min_keyword_length = 5,
              max_items = 5,
            },
            copilot = {
              name = "copilot",
              module = "blink-cmp-copilot",
              score_offset = 100,
              async = true,
              transform_items = function(_, items)
                local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
                local kind_idx = #CompletionItemKind + 1
                CompletionItemKind[kind_idx] = "Copilot"
                for _, item in ipairs(items) do
                  item.kind = kind_idx
                end
                return items
              end,
            },
            dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
            lazydev = {
              name = "LazyDev",
              module = "lazydev.integrations.blink",
              -- make lazydev completions top priority (see `:h blink.cmp`)
              score_offset = 100,
            },
            lsp = {
              min_keyword_length = 2, -- Number of characters to trigger provider
              score_offset = 0, -- Boost/penalize the score of the items
            },
            path = {
              min_keyword_length = 0,
            },
            snippets = {
              min_keyword_length = 1,
              opts = {
                search_paths = { "~/.config/nvim/lua/snippets" },
              },
            },
          },
        },
      },
    },
    -- required for jsonls and yamlls
    { "b0o/schemastore.nvim", lazy = true, version = false },
    {
      "glepnir/lspsaga.nvim",
      keys = function()
        return {
          { "<C-_>", "<cmd>Lspsaga term_toggle<CR>", mode = { "n", "t" } },
          { ",so", "<cmd>Lspsaga outline<CR>", mode = { "n", "t" } },
        }
      end,
      dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
      },
      opts = {
        symbol_in_winbar = {
          enable = true,
        },
        implement = {
          enable = true,
        },
        outline = {
          win_width = 50,
        },
        lightbulb = {
          enable = false,
        },
        rename = {
          project_max_width = 1.0,
        },
      },
      config = function(_, opts)
        require("lspsaga").setup(opts)
      end,
    },
  },
  opts = function()
    local ret = {
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          -- prefix = "●",
          prefix = "icons",
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = ICONS.diagnostics.Error,
            [vim.diagnostic.severity.WARN] = ICONS.diagnostics.Warn,
            [vim.diagnostic.severity.HINT] = ICONS.diagnostics.Hint,
            [vim.diagnostic.severity.INFO] = ICONS.diagnostics.Info,
          },
        },
      },
      inlay_hints = {
        enabled = true,
        exclude = { "vue" }, -- filetypes for which you don't want to enable inlay hints
      },
      codelens = {
        enabled = false,
      },
      capabilities = {
        workspace = {
          fileOperations = {
            didRename = true,
            willRename = true,
          },
        },
      },
      format = {
        formatting_options = nil,
        timeout_ms = nil,
      },
      -- LSP Server Settings
      servers = {
        gleam = {},
        gopls = {
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
        },
        jsonls = {
          -- lazy-load schemastore when needed
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
        },
        lexical = {
          cmd = { "/Users/aaustin/.local/share/nvim/mason/packages/lexical/libexec/lexical/bin/start_lexical.sh" },
        },
        lua_ls = {
          -- mason = false, -- set to false if you don't want this server to be installed with mason
          -- Use this to add any additional keymaps
          -- for specific lsp servers
          -- ---@type LazyKeysSpec[]
          -- keys = {},
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              -- workspace = {
              --   library = {
              --     [vim.fn.expand "$VIMRUNTIME/lua"] = true,
              --     [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
              --     ["/Users/aaustin/.hammerspoon/Spoons/EmmyLua.spoon/annotations"] = true,
              --   },
              -- },
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
          },
        },
        tailwindcss = {
          -- exclude a filetype from the default_config
          filetypes_exclude = { "markdown" },
          -- add additional filetypes to the default_config
          filetypes_include = {},
          -- to fully override the default_config, change the below
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
        },
        ts_ls = {
          enabled = false,
        },
        vtsls = {
          -- explicitly add default filetypes, so that we can extend
          -- them in related extras
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
                LSPUTILS.execute {
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
                LSPUTILS.execute {
                  command = "typescript.findAllFileReferences",
                  arguments = { vim.uri_from_bufnr(0) },
                  open = true,
                }
              end,
              desc = "File References",
            },
            {
              "<leader>co",
              LSPUTILS.action["source.organizeImports"],
              desc = "Organize Imports",
            },
            {
              "<leader>cM",
              LSPUTILS.action["source.addMissingImports.ts"],
              desc = "Add missing imports",
            },
            {
              "<leader>cu",
              LSPUTILS.action["source.removeUnused.ts"],
              desc = "Remove unused imports",
            },
            {
              "<leader>cD",
              LSPUTILS.action["source.fixAll.ts"],
              desc = "Fix all diagnostics",
            },
            {
              "<leader>cV",
              function()
                LSPUTILS.execute { command = "typescript.selectTypeScriptVersion" }
              end,
              desc = "Select TS workspace version",
            },
          },
        },
      },
      setup = {
        gopls = function(_, opts)
          -- workaround for gopls not supporting semanticTokensProvider
          -- https://github.com/golang/go/issues/54531#issuecomment-1464982242
          LSPUTILS.on_attach(function(client, _)
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
          end, "gopls")
          -- end workaround
        end,
        tailwindcss = function(lspconfig, opts)
          local tw = LSPUTILS.get_raw_config "tailwindcss"

          opts.init_options = {
            languages = {
              elixir = "phoenix-heex",
              eruby = "erb",
              heex = "phoenix-heex",
              svelte = "html",
            },
          }

          opts.handlers = {
            ["tailwindcss/getConfiguration"] = function(_, _, params, _, bufnr, _)
              vim.lsp.buf_notify(bufnr, "tailwindcss/getConfigurationResponse", { _id = params._id })
            end,
          }

          opts.filetypes = opts.filetypes or {}

          -- Add default filetypes
          vim.list_extend(opts.filetypes, tw.default_config.filetypes)

          -- Remove excluded filetypes
          --- @param ft string
          opts.filetypes = vim.tbl_filter(function(ft)
            return not vim.tbl_contains(opts.filetypes_exclude or {}, ft)
          end, opts.filetypes)

          -- Additional settings for Phoenix projects
          opts.settings = {
            tailwindCSS = {
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
          }

          -- Add additional filetypes
          vim.list_extend(opts.filetypes, opts.filetypes_include or {})
        end,
        ts_ls = function()
          -- disable tsserver
          return true
        end,
        vtsls = function(_, opts)
          LSPUTILS.on_attach(function(client, buffer)
            client.commands["_typescript.moveToFileRefactoring"] = function(command, ctx)
              ---@type string, string, lsp.Range
              local action, uri, range = unpack(command.arguments)

              local function move(newf)
                client.request("workspace/executeCommand", {
                  command = command.command,
                  arguments = { action, uri, range, newf },
                })
              end

              local fname = vim.uri_to_fname(uri)
              client.request("workspace/executeCommand", {
                command = "typescript.tsserverRequest",
                arguments = {
                  "getMoveToRefactoringFileSuggestions",
                  {
                    file = fname,
                    startLine = range.start.line + 1,
                    startOffset = range.start.character + 1,
                    endLine = range["end"].line + 1,
                    endOffset = range["end"].character + 1,
                  },
                },
              }, function(_, result)
                ---@type string[]
                local files = result.body.files
                table.insert(files, 1, "Enter new path...")
                vim.ui.select(files, {
                  prompt = "Select move destination:",
                  format_item = function(f)
                    return vim.fn.fnamemodify(f, ":~:.")
                  end,
                }, function(f)
                  if f and f:find "^Enter new path" then
                    vim.ui.input({
                      prompt = "Enter move destination:",
                      default = vim.fn.fnamemodify(fname, ":h") .. "/",
                      completion = "file",
                    }, function(newf)
                      return newf and move(newf)
                    end)
                  elseif f then
                    move(f)
                  end
                end)
              end)
            end
          end, "vtsls")
          -- copy typescript settings to javascript
          opts.settings.javascript =
            vim.tbl_deep_extend("force", {}, opts.settings.typescript, opts.settings.javascript or {})
        end,
      },
    }
    return ret
  end,
  config = function(_, opts)
    local lspconfig = require "lspconfig"

    -- setup on_attach
    LSPUTILS.on_attach(function(client, buffer)
      if client.supports_method "textDocument/formatting" then
        local format_on_save_group = vim.api.nvim_create_augroup("formatOnSave", {})

        vim.api.nvim_clear_autocmds { group = format_on_save_group, buffer = buffer }
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = format_on_save_group,
          buffer = buffer,
          callback = function()
            vim.lsp.buf.format { bufnr = buffer }
          end,
        })

        -- Enable completion triggered by <c-x><c-o>
        vim.bo[buffer].omnifunc = "v:lua.vim.lsp.omnifunc"

        require("config.keymaps").lsp_mappings(buffer)
      end
    end)

    -- diagnostics signs
    if vim.fn.has "nvim-0.10.0" == 0 then
      if type(opts.diagnostics.signs) ~= "boolean" then
        for severity, icon in pairs(opts.diagnostics.signs.text) do
          local name = vim.diagnostic.severity[severity]:lower():gsub("^%l", string.upper)
          name = "DiagnosticSign" .. name
          vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
        end
      end
    end

    if vim.fn.has "nvim-0.10" == 1 then
      -- inlay hints
      if opts.inlay_hints.enabled then
        LSPUTILS.on_supports_method("textDocument/inlayHint", function(client, buffer)
          if
            vim.api.nvim_buf_is_valid(buffer)
            and vim.bo[buffer].buftype == ""
            and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buffer].filetype)
          then
            vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
          end
        end)
      end

      -- code lens
      if opts.codelens.enabled and vim.lsp.codelens then
        LSPUTILS.on_supports_method("textDocument/codeLens", function(client, buffer)
          vim.lsp.codelens.refresh()
          vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
            buffer = buffer,
            callback = vim.lsp.codelens.refresh,
          })
        end)
      end
    end

    if type(opts.diagnostics.virtual_text) == "table" and opts.diagnostics.virtual_text.prefix == "icons" then
      opts.diagnostics.virtual_text.prefix = vim.fn.has "nvim-0.10.0" == 0 and "●"
        or function(diagnostic)
          local icons = ICONS.diagnostics
          for d, icon in pairs(icons) do
            if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
              return icon
            end
          end
        end
    end

    vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

    -- For blink.cmp
    local servers = opts.servers
    local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    local has_blink, blink = pcall(require, "blink.cmp")
    local capabilities = vim.tbl_deep_extend(
      "force",
      {},
      vim.lsp.protocol.make_client_capabilities(),
      has_cmp and cmp_nvim_lsp.default_capabilities() or {},
      has_blink and blink.get_lsp_capabilities() or {},
      opts.capabilities or {}
    )

    local function lsp_setup(server)
      local server_opts = vim.tbl_deep_extend("force", {
        capabilities = vim.deepcopy(capabilities),
      }, servers[server] or {})
      if server_opts.enabled == false then
        return
      end

      if opts.setup[server] then
        if opts.setup[server](server, server_opts) then
          return
        end
      elseif opts.setup["*"] then
        if opts.setup["*"](server, server_opts) then
          return
        end
      end
      lspconfig[server].setup(server_opts)
    end

    -- get all the servers that are available through mason-lspconfig
    local have_mason, mlsp = pcall(require, "mason-lspconfig")
    local all_mslp_servers = {}
    if have_mason then
      all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
    end

    local ensure_installed = {
      "cssls",
      "dockerls",
      "gopls",
      "graphql",
      "html",
      "lexical",
      "lua_ls",
      "rust_analyzer",
      "sqlls",
      "tailwindcss",
      "ts_ls",
      "typos_lsp",
      "yamlls",
      "zls",
    }
    for server, server_opts in pairs(servers) do
      if server_opts then
        server_opts = server_opts == true and {} or server_opts
        if server_opts.enabled ~= false then
          -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
          if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
            lsp_setup(server)
          else
            ensure_installed[#ensure_installed + 1] = server
          end
        end
      end
    end

    if have_mason then
      mlsp.setup {
        ensure_installed = vim.tbl_deep_extend(
          "force",
          ensure_installed,
          UTILS.opts("mason-lspconfig.nvim").ensure_installed or {}
        ),
        handlers = { lsp_setup },
        automatic_installation = true,
      }
    end
  end,
}
