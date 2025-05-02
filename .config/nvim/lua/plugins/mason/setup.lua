local lspconfig_present, lspconfig = pcall(require, "lspconfig")
local mason_lspconfig_present, mason_lspconfig = pcall(require, "mason-lspconfig")
local mason_present, mason = pcall(require, "mason")

local deps = {
  mason_present,
  mason_lspconfig_present,
  lspconfig_present,
}

if aa.contains(deps, false) then
  vim.notify "Failed to load dependencies in plugins/mason.lua"
  return
end

local M = {}

-- Sets up Mason and Mason LSP Config
M.setup = function()
  local root_pattern = lspconfig.util.root_pattern

  local package_list = {
    "actionlint",
    "ansible-lint",
    -- Python formatter
    "black",
    "codespell",
    -- Formatters (js, ts, tsx, etc.)
    "prettier",
    "prettierd",
    "biome",
    -- SHELL
    "shfmt",
    -- LUA
    "stylua",
    -- YAML
    "yamllint",
    "ansible-language-server",
    "bash-language-server",
    "clang-format",
    "clangd",
    "cmake-language-server",
    "commitlint",
    "css-lsp",
    "dockerfile-language-server",
    "elm-language-server",
    "eslint-lsp",
    "eslint_d",
    "go-debug-adapter",
    "goimports",
    "golangci-lint",
    "golangci-lint-langserver",
    "gomodifytags",
    "gopls",
    "helm-ls",
    "html-lsp",
    "json-lsp",
    "lexical",
    -- XML
    "lemminx",
    "lua-language-server",
    "powershell-editor-services",
    -- Markdown
    "prosemd-lsp",
    "python-lsp-server",
    -- SQL
    "sqlls",
    -- TailwindCSS
    "tailwindcss-language-server",
    "taplo",
    -- Terraform
    "terraform-ls",
    -- Typescript
    "typescript-language-server",
    "vtsls",
    -- VIM
    "vim-language-server",
    -- YAML
    "yaml-language-server",
    -- Zig
    "zls",

    -- DAP
    "bash-debug-adapter",
    "delve",
    "js-debug-adapter",

    -- Other utils
    "tree-sitter-cli",
  }

  ---@type MasonSettings
  mason.setup {}

  local mr = require "mason-registry"
  local function ensure_installed()
    for _, tool in ipairs(package_list) do
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

  lspconfig.nushell.setup {}

  mason_lspconfig.setup {}
  mason_lspconfig.setup_handlers {
    function(server_name)
      lspconfig[server_name].setup {}
    end,

    tailwindcss = function()
      lspconfig.tailwindcss.setup {
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
      }
    end,

    -- JSON
    jsonls = function()
      local overrides = require "plugins.lsp.jsonls"
      lspconfig.jsonls.setup(overrides)
    end,

    denols = function()
      lspconfig.denols.setup {
        lint = true,
        root_dir = root_pattern("deno.json", "deno.jsonc"),
      }
    end,

    -- Go
    gopls = function()
      local overrides = require "plugins.lsp.gopls"
      lspconfig.gopls.setup(overrides)
    end,

    -- Elixir
    lexical = function()
      lspconfig.lexical.setup {
        filetypes = { "elixir", "eelixir", "heex", "surface" },
        root_dir = function(fname)
          local matches = vim.fs.find({ "mix.exs" }, { upward = true, limit = 2, path = fname })
          local child_or_root_path, maybe_umbrella_path = unpack(matches)
          local root_dir = vim.fs.dirname(maybe_umbrella_path or child_or_root_path)

          return root_dir
        end,
        single_file_support = true,
        dialyzer_enabled = true,
      }
    end,

    -- Lua
    lua_ls = function()
      local overrides = require "plugins.lsp.lua_ls"
      lspconfig.lua_ls.setup(overrides)
    end,

    -- TypeScript
    ts_ls = function()
      lspconfig.ts_ls.setup {
        enabled = false,
      }
    end,

    vtsls = function()
      local overrides = require "plugins.lsp.vtsls"
      lspconfig.vtsls.setup(overrides)
    end,

    -- YAML
    yamlls = function()
      local overrides = require "plugins.lsp.yamlls"
      lspconfig.yamlls.setup(overrides)
    end,
  }
end

return M
