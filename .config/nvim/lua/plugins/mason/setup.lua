local utils = require "config.utils"

local lspconfig_present, lspconfig = pcall(require, "lspconfig")
local mason_lspconfig_present, mason_lspconfig = pcall(require, "mason-lspconfig")
local mason_present, mason = pcall(require, "mason")

local deps = {
  mason_present,
  mason_lspconfig_present,
  lspconfig_present,
}

if utils.contains(deps, false) then
  vim.notify "Failed to load dependencies in plugins/mason.lua"
  return
end

local M = {}

-- Sets up Mason and Mason LSP Config
M.setup = function()
  local root_pattern = lspconfig.util.root_pattern

  local package_list = {
    -- Null LS
    "actionlint",
    "ansible-lint",
    -- python formatter
    "black",
    "codespell",
    "prettierd",
    "stylua",
    "yamllint",

    -- LSPs
    "ansible-language-server",
    "arduino-language-server",
    "bash-language-server",
    "clang-format",
    "clangd",
    "cmake-language-server",
    "commitlint",
    "css-lsp",
    "dockerfile-language-server",
    "elm-language-server",
    "erlang-ls",
    "lexical",
    "eslint-lsp",
    "go-debug-adapter",
    "goimports",
    "golangci-lint",
    "golangci-lint-langserver",
    "gomodifytags",
    "gopls",
    "helm-ls",
    "html-lsp",
    "json-lsp",
    -- XML
    "lemminx",
    "lua-language-server",
    -- Markdown
    "prosemd-lsp",
    "python-lsp-server",
    "rust-analyzer",
    "sqlls",
    "tailwindcss-language-server",
    "taplo",
    "terraform-ls",
    "typescript-language-server",
    "vim-language-server",
    "yaml-language-server",
    "zls",

    -- Other utils
    "tree-sitter-cli",
  }

  ---@diagnostic disable-next-line: redundant-parameter
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

  mason_lspconfig.setup {}
  mason_lspconfig.setup_handlers {
    function(server_name)
      lspconfig[server_name].setup {}
    end,

    ["tailwindcss"] = function()
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
    end,

    -- JSON
    ["jsonls"] = function()
      local overrides = require "plugins.lspsettings.jsonls"
      lspconfig.jsonls.setup(overrides)
    end,

    -- YAML
    ["yamlls"] = function()
      local overrides = require("plugins.lspsettings.yamlls").setup()
      lspconfig.yamlls.setup(overrides)
    end,

    -- Lua
    ["lua_ls"] = function()
      local overrides = require "plugins.lspsettings.lua_ls"
      lspconfig.lua_ls.setup(overrides)
    end,

    -- Elixir
    ["lexical"] = function()
      local overrides = require "plugins.lspsettings.lexical"
      lspconfig.lexical.setup(overrides)
    end,

    -- GO
    ["gopls"] = function()
      local overrides = require "plugins.lspsettings.gopls"
      lspconfig.gopls.setup(overrides)
    end,
  }
end

return M
