return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "jose-elias-alvarez/nvim-lsp-ts-utils",
    "folke/lsp-colors.nvim",
    {
      "glepnir/lspsaga.nvim",
      config = function()
        require("lspsaga").setup({
          symbol_in_winbar = {
            enable = true,
          },
        })
      end,
    },
  },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = {
        "dockerls",
        "elixirls",
        "grammarly",
        "graphql",
        "sqlls",
        "lua_ls",
        "tsserver",
        "yamlls",
        "rust_analyzer",
        "zls",
      },
      automatic_installlation = true,
    })

    local lspconfig = require("lspconfig")

    local buf_map = function(bufnr, mode, lhs, rhs, opts)
      vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts or {
        silent = true,
      })
    end

    local format_on_save_group = vim.api.nvim_create_augroup("formatOnSave", {})

    -- For nvim-cmp
    local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
    local on_attach = function(client, bufnr)
      require("keymaps").lsp_mappings(bufnr)
      require("keymaps").lsp_diagnostic_mappings()

      local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
      end

      buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

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
      vim.api.nvim_create_user_command("Format", function()
        vim.lsp.buf.format({ async = true })
      end, {})

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

    -- mason-lspconfig
    require("mason-lspconfig").setup_handlers({
      function(server_name) -- default handler (optional)
        lspconfig[server_name].setup({})
      end,
      ["elixirls"] = function()
        local child_or_root_path = vim.fs.dirname(vim.fs.find({ "mix.exs", ".git" }, { upward = true })[1])
        local maybe_umbrella_path =
            vim.fs.dirname(vim.fs.find({ "mix.exs" }, { upward = true, path = child_or_root_path })[1])

        if maybe_umbrella_path then
          local Path = require("plenary.path")
          if not vim.startswith(child_or_root_path, Path:joinpath(maybe_umbrella_path, "apps"):absolute()) then
            maybe_umbrella_path = nil
          end
        end

        local root_dir = maybe_umbrella_path or child_or_root_path or vim.loop.os_homedir()
        local path_to_elixirls = vim.fn.expand("~/elixir-ls/release/language_server.sh")

        opts.settings = {
          cmd = { path_to_elixirls },
          elixirLS = {
            fetchDeps = false,
            dialyzerEnabled = true,
            dialyzerFormat = "dialyxir_short",
            suggestSpecs = true,
            root_dir = root_dir,
          },
        }
        lspconfig.elixirls.setup(opts)
      end,
      ["lua_ls"] = function()
        opts.settings = {
          Lua = {
            diagnostics = {
              globals = { "vim", "hs" },
            },
            workspace = {
              library = {
                [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
                ["/Users/nandofarias/.hammerspoon/Spoons/EmmyLua.spoon/annotations"] = true,
              },
            },
          },
        }

        lspconfig.lua_ls.setup(opts)
      end,
      ["tsserver"] = function()
        opts.on_attach = function(client, bufnr)
          client.server_capabilities.document_formatting = false
          client.server_capabilities.document_range_formatting = false
          local ts_utils = require("nvim-lsp-ts-utils")
          ts_utils.setup({})
          ts_utils.setup_client(client)
          buf_map(bufnr, "n", "gs", ":TSLspOrganize<CR>")
          buf_map(bufnr, "n", "gi", ":TSLspRenameFile<CR>")
          buf_map(bufnr, "n", "go", ":TSLspImportAll<CR>")
          on_attach(client, bufnr)
        end

        lspconfig.tsserver.setup(opts)
      end,
      ["grammarly"] = function()
        opts.init_options = { clientId = "client_BaDkMgx4X19X9UxxYRCXZo" }
        lspconfig.grammarly.setup(opts)
      end,
    })
  end,
}
