-- installs/updates LSPs, linters and DAPs
return {
  "williamboman/mason.nvim",
  keys = function()
    return {
      { "<leader>lr", "<cmd>LspRestart<CR>", desc = "Restart LSP" },
      { "<leader>li", "<cmd>LspInfo<CR>", desc = "LSP Info" },
    }
  end,
  build = ":MasonUpdate",
  cmd = { "Mason", "MasonUpdate", "MasonUpdateAll" },
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    -- handles connection of LSP Configs and Mason
    "williamboman/mason-lspconfig.nvim",

    -- adds MasonUpdateAll
    "Zeioth/mason-extra-cmds",

    -- Collection of configurations for the built-in LSP client
    "neovim/nvim-lspconfig",

    -- required for setting up capabilities for cmp
    "hrsh7th/cmp-nvim-lsp",

    -- required for jsonls and yamlls
    { "b0o/schemastore.nvim", lazy = true, version = false },
  },
  opts = {
    ensure_installed = {
      -- Formatters and Linters
      "black",
      "codespell",
      "eslint_d",
      "prettier",
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
      "goimports",
      "golangci-lint",
      "golangci-lint-langserver",
      "gomodifytags",
      "gopls",
      "html-lsp",
      "json-lsp",
      "lexical",
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
    },
  },
  config = function(_self, opts)
    require("plugins.mason.lsp").setup()
    require("plugins.mason.setup").setup(opts)
  end,
}
