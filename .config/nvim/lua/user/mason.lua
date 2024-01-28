local M = {
  "williamboman/mason.nvim",
  cmd = "Mason",
  keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
  build = ":MasonUpdate",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
  },
  opts = {
    ensure_installed = {
      "black",
      "codespell",
      "delve",
      "eslint_d",
      "gofumpt",
      "goimports",
      "gomodifytags",
      "impl",
      "isort",
      "prettier",
      "pylint",
      "stylua",
      "tflint",
    },
    ui = {
      border = "single",
      width = 0.7,
      height = 0.8,
    },
  },
}

function M.config(_, mason_opts)
  require("mason").setup(mason_opts)

  local mr = require("mason-registry")
  local function ensure_installed()
    for _, tool in ipairs(mason_opts.ensure_installed) do
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

  require("mason-lspconfig").setup({
    ensure_installed = {
      "bashls",
      "cssls",
      "dockerls",
      "eslint",
      "html",
      "pyright",
      "graphql",
      "jsonls",
      "lua_ls",
      "pyright",
      "rust_analyzer",
      "sqlls",
      "terraformls",
      "tsserver",
      "yamlls",
    },
    automatic_installlation = true,
  })
end

return M
