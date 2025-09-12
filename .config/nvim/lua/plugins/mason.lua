---@type LazySpec
return {
  "mason-org/mason.nvim",
  -- temporarily lock to v1 to avoid dealing with breaking changes - after v2
  -- stabilizes this can be updated to 2.0.0 or removed
  build = ":MasonUpdate",
  cmd = { "Mason", "MasonUpdate", "MasonUpdateAll" },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local mason = require "mason"

    local package_list = {
      -- Null LS
      "biome",
      "black",
      "eslint_d",
      "prettier",
      "prettierd",
      "stylua",
      "yamllint",

      -- LSPs
      "ansible-language-server",
      "bash-language-server",
      "commitlint",
      "css-lsp",
      "dockerfile-language-server",
      "dprint",
      "eslint-lsp",
      "erlang-ls",
      "expert",
      "go-debug-adapter",
      "goimports",
      "golangci-lint",
      "golangci-lint-langserver",
      "gomodifytags",
      "gopls",
      "helm-ls",
      "html-lsp",
      "json-lsp",
      "lemminx",
      "lua-language-server",
      "marksman",
      "python-lsp-server",
      "rust-analyzer",
      "shellcheck",
      "sqlls",
      "tailwindcss-language-server",
      "taplo",
      "terraform-ls",
      "typescript-language-server",
      "typos",
      "typos-lsp",
      "vim-language-server",
      "yaml-language-server",
      "vtsls",
    }

    mason.setup {}

    -- Auto install all packages in the package_list
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
  end,
}
