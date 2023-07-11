local utils = require("utils")

local cmp_lsp_present, cmp_lsp = pcall(require, "cmp_nvim_lsp")
local lspconfig_present, lspconfig = pcall(require, "lspconfig")
local mason_lspconfig_present, mason_lspconfig = pcall(require, "mason-lspconfig")
local mason_present, mason = pcall(require, "mason")
local ts_utils_present, ts_utils = pcall(require, "nvim-lsp-ts-utils")
local elixir_present, elixir = pcall(require, "elixir")

local deps = {
  cmp_lsp_present,
  elixir_present,
  lspconfig_present,
  mason_lspconfig_present,
  mason_present,
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
      -- "elixirls",
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

  -- add completion and documentation capabilities for cmp completion
  local capabilities = cmp_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
      local bufnr = ev.buf
      -- Enable completion triggered by <c-x><c-o>
      vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

      require("keymaps").lsp_mappings(bufnr)
      require("keymaps").lsp_diagnostic_mappings()
    end,
  })

  local format_on_save_group = vim.api.nvim_create_augroup("formatOnSave", {})
  local on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") or client.supports_method("textDocument/rangeFormatting") then
      vim.api.nvim_clear_autocmds({ group = format_on_save_group, buffer = bufnr })
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

  local elixirls = require("elixir.elixirls")
  elixir.setup({
    elixirls = {
      on_attach = on_attach,
      settings = elixirls.settings({
        dialyzerEnabled = true,
        fetchDeps = false,
        enableTestLenses = true,
        suggestSpecs = false,
      }),
    },
  })

  mason_lspconfig.setup_handlers({
    function(server_name)
      lspconfig[server_name].setup({})
    end,

    -- ["elixirls"] = function()
    --   opts.settings = {
    --     elixirLS = {
    --       fetchDeps = false,
    --       dialyzerEnabled = true,
    --       dialyzerFormat = "dialyxir_short",
    --       suggestSpecs = true,
    --     },
    --   }
    --   opts.root_dir = function(fname)
    --     local path = lspconfig.util.path
    --     local child_or_root_path = lspconfig.util.root_pattern({ "mix.exs", ".git" })(fname)
    --     local maybe_umbrella_path =
    --       lspconfig.util.root_pattern({ "mix.exs" })(vim.loop.fs_realpath(path.join({ child_or_root_path, ".." })))
    --
    --     local has_ancestral_mix_exs_path =
    --       vim.startswith(child_or_root_path, path.join({ maybe_umbrella_path, "apps" }))
    --     if maybe_umbrella_path and not has_ancestral_mix_exs_path then
    --       maybe_umbrella_path = nil
    --     end
    --
    --     return maybe_umbrella_path or child_or_root_path or vim.loop.os_homedir()
    --   end
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

    -- JSON
    ["jsonls"] = function()
      local overrides = require("plugins.lsp.jsonls")
      lspconfig.jsonls.setup(overrides)
    end,

    -- YAML
    ["yamlls"] = function()
      local overrides = require("plugins.lsp.yamlls").setup()
      lspconfig.yamlls.setup(overrides)
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
  })
end

return M
