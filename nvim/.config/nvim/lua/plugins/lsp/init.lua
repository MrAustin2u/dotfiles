return {
  -- lspconfig
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    keys = { { "<leader>cs", "<cmd>LspRestart<cr>", desc = "Lsp Restart" } },
    dependencies = {
      { "folke/neoconf.nvim", cmd = "Neoconf", config = true },
      { "folke/neodev.nvim", opts = { experimental = { pathStrict = true } } },
      "mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      {
        "mhanberg/elixir.nvim",
        cond = function()
          return require("lazyvim.util").has("elixir.language_server")
        end,
      },
      {
        "hrsh7th/cmp-nvim-lsp",
        cond = function()
          return require("lazyvim.util").has("nvim-cmp")
        end,
      },
    },
    ---@class PluginLspOpts
    opts = function()
      local lspconfig = require("lspconfig")
      local elixir = require("elixir.language_server")
      local root_pattern = lspconfig.util.root_pattern

      return {
        -- options for vim.diagnostic.config()
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = { spacing = 4, prefix = "●" },
          severity_sort = true,
        },
        -- Automatically format on save
        autoformat = true,
        -- options for vim.lsp.buf.format
        -- `bufnr` and `filter` is handled by the LazyVim formatter,
        -- but can be also overriden when specified
        format = {
          formatting_options = nil,
          timeout_ms = nil,
        },
        -- LSP Server Settings
        ---@type lspconfig.options
        servers = {
          jsonls = {},
          lua_ls = {
            -- mason = false, -- set to false if you don't want this server to be installed with mason
            settings = {
              Lua = {
                runtime = {
                  -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                  version = "LuaJIT",
                },
                diagnostics = {
                  -- Get the language server to recognize the `vim` global
                  globals = { "vim" },
                },
                workspace = {
                  checkThirdParty = false,
                  -- Make the server aware of Neovim runtime files
                  library = vim.api.nvim_get_runtime_file("", true),
                },
                completion = {
                  callSnippet = "Replace",
                },
              },
            },
          },
        },
        -- you can do any additional lsp server setup here
        -- return true if you don't want this server to be setup with lspconfig
        ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
        setup = {
          -- example to setup with typescript.nvim
          -- tsserver = function(_, opts)
          --   require("typescript").setup({ server = opts })
          --   return true
          -- end,
          -- Specify * to use this function as a fallback for any server
          -- ["*"] = function(server, opts) end,

          -- Elixir
          ["elixirls"] = function()
            lspconfig.elixirls.setup({
              settings = elixir.settings({}),
              on_attach = elixir.on_attach,
            })
          end,

          -- Tailwindcss
          ["tailwindcss"] = function()
            lspconfig.tailwindcss.setup({
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
        },
      }
    end,
    ---@param opts PluginLspOpts
    config = function(plugin, opts)
      -- setup autoformat
      require("lazyvim.plugins.lsp.format").autoformat = opts.autoformat
      -- setup formatting and keymaps
      require("lazyvim.util").on_attach(function(client, buffer)
        require("lazyvim.plugins.lsp.format").on_attach(client, buffer)
        require("lazyvim.plugins.lsp.keymaps").on_attach(client, buffer)
      end)

      -- diagnostics
      for name, icon in pairs(require("lazyvim.config").icons.diagnostics) do
        name = "DiagnosticSign" .. name
        vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
      end
      vim.diagnostic.config(opts.diagnostics)

      local servers = opts.servers
      local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

      local function setup(server)
        local server_opts = servers[server] or {}
        server_opts.capabilities = capabilities
        if opts.setup[server] then
          if opts.setup[server](server, server_opts) then
            return
          end
        elseif opts.setup["*"] then
          if opts.setup["*"](server, server_opts) then
            return
          end
        end
        require("lspconfig")[server].setup(server_opts)
      end

      local mlsp = require("mason-lspconfig")
      local available = mlsp.get_available_servers()

      local ensure_installed = { "elixirls" } ---@type string[]
      for server, server_opts in pairs(servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
          if server_opts.mason == false or not vim.tbl_contains(available, server) then
            setup(server)
          else
            ensure_installed[#ensure_installed + 1] = server
          end
        end
      end

      require("mason-lspconfig").setup({ ensure_installed = ensure_installed })
      require("mason-lspconfig").setup_handlers({ setup })
    end,
  },

  -- formatters
  {
    "jose-elias-alvarez/null-ls.nvim",
    event = "BufReadPre",
    dependencies = { "mason.nvim", "lukas-reineke/lsp-format.nvim" },
    opts = function()
      local b = require("null-ls").builtins
      local lsp_format = require("lsp-format")

      return {
        sources = {
          ----------------------
          --      Hover      --
          ----------------------
          b.hover.dictionary,
          ----------------------
          --    Formatting   --
          ----------------------
          b.formatting.prettierd,
          b.formatting.stylua,
          -- Doesn't work for heex files
          b.formatting.mix.with({
            extra_filetypes = { "eelixir", "heex" },
            args = { "format", "-" },
            extra_args = function(_params)
              local version_output = vim.fn.system("elixir -v")
              local minor_version = vim.fn.matchlist(version_output, "Elixir \\d.\\(\\d\\+\\)")[2]

              local extra_args = {}

              -- tells the formatter the filename for the code passed to it via stdin.
              -- This allows formatting heex files correctly. Only available for
              -- Elixir >= 1.14
              if tonumber(minor_version, 10) >= 14 then
                extra_args = { "--stdin-filename", "$FILENAME" }
              end

              return extra_args
            end,
          }),
          b.formatting.pg_format,
          b.formatting.shfmt,
          b.formatting.golines,
          ----------------------
          --    Diagnostics   --
          ----------------------
          b.diagnostics.flake8,
          b.diagnostics.golangci_lint,
          b.diagnostics.credo.with({
            -- run credo in strict mode even if strict mode is not enabled in
            -- .credo.exs
            extra_args = { "--strict" },
            -- only register credo source if it is installed in the current project
            condition = function(_utils)
              local cmd = { "rg", ":credo", "mix.exs" }
              local credo_installed = ("" == vim.fn.system(cmd))
              return not credo_installed
            end,
          }),
          b.diagnostics.yamllint,
          b.diagnostics.zsh,
          ----------------------
          --    Code Action   --
          ----------------------
          b.code_actions.eslint_d,
        },
        on_attach = function(client)
          if client.supports_method("textDocument/formatting") then
            lsp_format.on_attach(client)
          end
        end,
      }
    end,
  },

  -- cmdline tools and lsp servers
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    opts = {
      ensure_installed = {
        -- Null LS
        "actionlint",
        "codespell",
        "eslint_d",
        "prettierd",
        "shellcheck",
        "stylua",
        "yamllint",

        -- LSPs

        "bash-language-server",
        "css-lsp",
        "dockerfile-language-server",
        "elixir-ls",
        "elm-language-server",
        "eslint-lsp",
        "gopls",
        "html-lsp",
        "json-lsp",
        "lua-language-server",
        "rust-analyzer",
        "sqlls",
        "tailwindcss-language-server",
        "terraform-ls",
        "typescript-language-server",
        "vim-language-server",
        "yaml-language-server",
      },
    },
    ---@param opts MasonSettings | {ensure_installed: string[]}
    config = function(plugin, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      for _, tool in ipairs(opts.ensure_installed) do
        local p = mr.get_package(tool)
        if not p:is_installed() then
          p:install()
        end
      end
    end,
  },
}
