local utils = require("utils")

local cmp_lsp_present, cmp_lsp = pcall(require, "cmp_nvim_lsp")
local elixir_present, elixir = pcall(require, "elixir")
local lspconfig_present, lspconfig = pcall(require, "lspconfig")
local mason_lspconfig_present, mason_lspconfig = pcall(require, "mason-lspconfig")
local mason_present, mason = pcall(require, "mason")
local mason_tool_installer_present, mason_tool_installer = pcall(require, "mason-tool-installer")
local ts_utils_present, ts_utils = pcall(require, "nvim-lsp-ts-utils")

local deps = {
  cmp_lsp_present,
  elixir_present,
  lspconfig_present,
  mason_lspconfig_present,
  mason_present,
  mason_tool_installer_present,
  ts_utils_present,
}

if utils.contains(deps, false) then
  vim.notify("Failed to load dependencies in plugins/init.lua")
  return
end

local M = {}
M.setup = function()
  mason.setup()
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

  mason_tool_installer.setup({
    ensure_installed = {
      "black",
      "eslint_d",
      "isort",
      "prettier",
      "pylint",
      "stlua"
    }
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
      vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

      vim.api.nvim_create_user_command("Format", function()
        vim.lsp.buf.format({ async = true })
      end, {})

      require("keymaps").lsp_mappings()
      require("keymaps").lsp_diagnostic_mappings()
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
        buffer = bufnr
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

  local opts = {
    capabilities = create_capabilities(),
    on_attach = on_attach,
  }

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
        require("keymaps").elixir_mappings()
        on_attach(client, bufnr)
      end,
    },
  })

  mason_lspconfig.setup_handlers({
    function(server_name)
      lspconfig[server_name].setup({})
    end,

    -- ["elixirls"] = function()
    --   opts.cmd = { vim.fn.expand("~/.local/share/nvim/lsp_servers/elixir/elixir-ls/release/language_server.sh") }
    --   opts.root_dir = root_pattern("mix.exs", ".git") or vim.loop.os_homedir()
    --   opts.settings = {
    --     elixirLS = {
    --       fetchDeps = false,
    --       dialyzerEnabled = true,
    --       dialyzerFormat = "dialyxir_short",
    --       suggestSpecs = true,
    --     },
    --   }
    --
    --   lspconfig.elixirls.setup(opts)
    -- end,

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

    ["tsserver"] = function()
      opts.on_attach = function(client, bufnr)
        client.server_capabilities.document_formatting = false
        client.server_capabilities.document_range_formatting = false
        ts_utils.setup({})
        ts_utils.setup_client(client)
        vim.keymap.set("n", "gs", ":TSLspOrganize<CR>", { silent = true, buffer = bufnr })
        vim.keymap.set("n", "gi", ":TSLspRenameFile<CR>", { silent = true, buffer = bufnr })
        vim.keymap.set("n", "go", ":TSLspImportAll<CR>", { silent = true, buffer = bufnr })
        on_attach(client, bufnr)
      end

      lspconfig.tsserver.setup(opts)
    end,

    -- YAML
    ["yamlls"] = function()
      local overrides = require("plugins.lsp.yamlls").setup()
      lspconfig.yamlls.setup(overrides)
    end,
  })
end

return M
