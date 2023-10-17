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
    },
    config = function()
      local cmp_lsp = require("cmp_nvim_lsp")
      local lspconfig = require("lspconfig")
      local mason_lspconfig = require("mason-lspconfig")

      mason_lspconfig.setup({
        ensure_installed = {
          "cssls",
          "gopls",
          "elixirls",
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

      local format_on_save_group = vim.api.nvim_create_augroup("formatOnSave", {})

      -- For nvim-cmp
      local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

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

      local on_attach = function(client, bufnr)
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

      local opts = {
        capabilities = capabilities,
        on_attach = on_attach,
      }

      mason_lspconfig.setup_handlers({
        function(server_name)
          lspconfig[server_name].setup({})
        end,

        ['elixirls'] = function()
          opts.settings = {
            elixirLS = {
              fetchDeps = false,
              dialyzerEnabled = true,
              dialyzerFormat = 'dialyxir_short',
              suggestSpecs = true
            }
          }
          opts.root_dir = function(fname)
            local path = lspconfig.util.path
            local child_or_root_path = lspconfig.util.root_pattern({ "mix.exs", ".git" })(fname)
            local maybe_umbrella_path = lspconfig.util.root_pattern({ "mix.exs" })(
              vim.loop.fs_realpath(path.join({ child_or_root_path, ".." }))
            )

            local has_ancestral_mix_exs_path = vim.startswith(child_or_root_path,
              path.join({ maybe_umbrella_path, "apps" }))
            if maybe_umbrella_path and not has_ancestral_mix_exs_path then
              maybe_umbrella_path = nil
            end

            return maybe_umbrella_path or child_or_root_path or vim.loop.os_homedir()
          end


          lspconfig.elixirls.setup(opts)
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
