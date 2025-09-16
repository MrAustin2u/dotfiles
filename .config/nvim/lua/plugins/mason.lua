---@type LazySpec
return {
  "mason-org/mason.nvim",
  lazy = false,
  keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
  opts = {
    ensure_installed = {
      -- Null LS
      "biome",
      "black",
      "eslint_d",
      "prettier",
      "prettierd",
      "stylua",
      "yamllint",
      "ansible-lint",
      "actionlint",

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
      "graphql-language-service-cli",
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
      "typos",
      "typos-lsp",
      "vim-language-server",
      "yaml-language-server",
      "vtsls",
    },
  },
  config = function(_, opts)
    -- PATH is handled by core.mason-path for consistency
    require("mason").setup(opts)

    -- Auto-install ensure_installed tools with better error handling
    local mr = require "mason-registry"
    local function ensure_installed()
      for _, tool in ipairs(opts.ensure_installed) do
        if mr.has_package(tool) then
          local p = mr.get_package(tool)
          if not p:is_installed() then
            vim.notify("Mason: Installing " .. tool .. "...", vim.log.levels.INFO)
            p:install():once("closed", function()
              if p:is_installed() then
                vim.notify("Mason: Successfully installed " .. tool, vim.log.levels.INFO)
              else
                vim.notify("Mason: Failed to install " .. tool, vim.log.levels.ERROR)
              end
            end)
          end
        else
          vim.notify("Mason: Package '" .. tool .. "' not found", vim.log.levels.WARN)
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
