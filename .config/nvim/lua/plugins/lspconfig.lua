return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "jose-elias-alvarez/nvim-lsp-ts-utils",
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
              min_keyword_length = 2, -- Number of characters to trigger porvider
              score_offset = 0,       -- Boost/penalize the score of the items
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
          { ",so",   "<cmd>Lspsaga outline<CR>",     mode = { "n", "t" } },
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
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup {
      ensure_installed = {
        "cssls",
        "dockerls",
        "erlangls",
        "gopls",
        "grammarly",
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
      },
      automatic_installlation = true,
    }

    local lspconfig = require "lspconfig"

    -- For blink.cmp
    local capabilities = require("blink.cmp").get_lsp_capabilities()

    local on_attach = function(client, bufnr)
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

    -- manual lspconfig
    lspconfig.gleam.setup(opts)

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

        require("config.keymaps").lsp_mappings(ev.buf)

        vim.api.nvim_create_user_command("Format", function()
          vim.lsp.buf.format { async = true }
        end, {})
      end,
    })

    -- mason-lspconfig
    require("mason-lspconfig").setup_handlers {
      function(server_name)
        require("lspconfig")[server_name].setup {}
      end,

      ["elixirls"] = function()
        opts.settings = {
          elixirLS = {
            fetchDeps = false,
            dialyzerEnabled = true,
            dialyzerFormat = "dialyxir_short",
            suggestSpecs = true,
          },
        }

        lspconfig.elixirls.setup(opts)
      end,

      ["gopls"] = function()
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

      ["jsonls"] = function()
        opts.settings = {
          json = {
            format = { enable = false },
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        }
        lspconfig.jsonls.setup(opts)
      end,

      ["lexical"] = function()
        lspconfig.lexical.setup {
          default_config = {
            filetypes = { "elixir", "eelixir", "heex" },
            cmd = { "$HOME/.local/share/nvim/mason/packages/lexical/libexec/lexical/bin/start_lexical.sh" },
            settings = {},
          },
        }
      end,

      ["lua_ls"] = function()
        opts.settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
            },
            diagnostics = {
              globals = { "vim", "hs" },
            },
            workspace = {
              library = {
                [vim.fn.expand "$VIMRUNTIME/lua"] = true,
                [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
                ["/Users/aaustin/.hammerspoon/Spoons/EmmyLua.spoon/annotations"] = true,
              },
            },
          },
        }

        lspconfig.lua_ls.setup(opts)
      end,

      ["tailwindcss"] = function()
        lspconfig.tailwindcss.setup {
          root_dir = lspconfig.util.root_pattern,
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

        lspconfig.tailwindcss.setup(opts)
      end,

      ["ts_ls"] = function()
        opts.on_attach = function(client, bufnr)
          client.server_capabilities.document_formatting = false
          client.server_capabilities.document_range_formatting = false
          local ts_utils = require "nvim-lsp-ts-utils"
          ts_utils.setup {}
          ts_utils.setup_client(client)
          vim.keymap.set("n", "<leader>gs", ":TSLspOrganize<CR>", { silent = true, buffer = bufnr })
          vim.keymap.set("n", "<leader>gr", ":TSLspRenameFile<CR>", { silent = true, buffer = bufnr })
          vim.keymap.set("n", "<leader>ga", ":TSLspImportAll<CR>", { silent = true, buffer = bufnr })
          on_attach(client, bufnr)
        end

        lspconfig.ts_ls.setup(opts)
      end,

      ["grammarly"] = function()
        opts.init_options = { clientId = "client_BaDkMgx4X19X9UxxYRCXZo" }
        lspconfig.grammarly.setup(opts)
      end,
    }
  end,
}
