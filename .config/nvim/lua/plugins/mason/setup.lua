local UTILS = require "config.utils"

local lspconfig_present, lspconfig = pcall(require, "lspconfig")
local mason_lspconfig_present, mason_lspconfig = pcall(require, "mason-lspconfig")
local mason_present, mason = pcall(require, "mason")

local deps = {
  mason_present,
  mason_lspconfig_present,
  lspconfig_present,
}

if UTILS.contains(deps, false) then
  vim.notify "Failed to load dependencies in plugins/mason.lua"
  return
end

local M = {}

-- Sets up Mason and Mason LSP Config
M.setup = function()
  local root_pattern = lspconfig.util.root_pattern

  local package_list = {

    -- Formatters and Linters
    "black",
    "codespell",
    "prettierd",
    "shfmt",
    "stylua",
    "yamllint",
    "actionlint",
    "ansible-lint",

    -- LSPs
    "bash-language-server",
    "clang-format",
    "css-lsp",
    "dockerfile-language-server",
    "eslint-lsp",
    "goimports",
    "golangci-lint",
    "golangci-lint-langserver",
    "gomodifytags",
    "gopls",
    "html-lsp",
    "json-lsp",
    "lua-language-server",
    "prosemd-lsp",
    "python-lsp-server",
    "rust-analyzer",
    "sqlls",
    "tailwindcss-language-server",
    "terraform-ls",
    "vim-language-server",
    "vtsls",
    "yaml-language-server",
    "zls",
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

  mason_lspconfig.setup {}
  mason_lspconfig.setup_handlers {
    function(server_name)
      lspconfig[server_name].setup {}
    end,

    -- elixir
    ["lexical"] = function()
      local overrides = require("plugins.lsp.configs.lexical").setup {
        lspconfig = lspconfig,
        root_pattern = root_pattern,
      }
      lspconfig.lexical.setup(overrides)
    end,

    -- go
    ["gopls"] = function()
      local overrides = require "plugins.lsp.configs.gopls"
      lspconfig.gopls.setup(overrides)
    end,

    -- json
    ["jsonls"] = function()
      local overrides = require "plugins.lsp.configs.jsonls"
      lspconfig.jsonls.setup(overrides)
    end,

    -- lua
    ["lua_ls"] = function()
      local overrides = require "plugins.lsp.configs.lua_ls"
      lspconfig.lua_ls.setup(overrides)
    end,

    -- tailwindcss
    ["tailwindcss"] = function()
      local overrides = require("plugins.lsp.configs.tailwindcss").setup { root_pattern = root_pattern }
      lspconfig.tailwindcss.setup(overrides)
    end,

    -- typescript
    ["vtsls"] = function()
      local overrides = require "plugins.lsp.configs.vtsls"
      lspconfig.vtsls.setup(overrides)
    end,

    -- yaml
    ["yamlls"] = function()
      local overrides = require "plugins.lsp.configs.yamlls"
      lspconfig.yamlls.setup(overrides)
    end,
  }
end

return M
