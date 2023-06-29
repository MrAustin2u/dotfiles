return {
  "jose-elias-alvarez/null-ls.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "lukas-reineke/lsp-format.nvim",
    "mason.nvim",
  },
  config = function()
    local null_ls_present, null_ls = pcall(require, "null-ls")
    local lsp_format_present, lsp_format = pcall(require, "lsp-format")

    if not null_ls_present or not lsp_format_present then
      vim.notify("Failed to set up null-ls and lsp-format")
      return
    end

    local b = null_ls.builtins

    null_ls.setup({
      root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git"),
      sources = {
        ----------------------
        --   Code Actions   --
        ----------------------
        -- b.code_actions.eslint_d,
        b.code_actions.shellcheck,
        b.code_actions.gomodifytags,
        require("typescript.extensions.null-ls.code-actions"),

        ----------------------
        --    Diagnostics   --
        ----------------------
        b.diagnostics.actionlint,
        -- b.diagnostics.codespell,
        b.diagnostics.eslint_d,
        b.diagnostics.rubocop,
        b.diagnostics.shellcheck,
        b.diagnostics.yamllint,
        b.diagnostics.zsh,
        -- b.diagnostics.credo.with({
        --   condition = function(utils)
        --     return utils.root_has_file(".credo.exs")
        --   end,
        -- }),

        ----------------------
        --    Formatters    --
        ----------------------
        -- Doesn't work for heex files
        -- b.formatting.mix.with({
        --   extra_filetypes = { "eelixir", "heex" },
        --   args = { "format", "-" },
        --   ---@diagnostic disable-next-line: unused-local
        --   extra_args = function(_params)
        --     local version_output = vim.fn.system("elixir -v")
        --     local minor_version = vim.fn.matchlist(version_output, "Elixir \\d.\\(\\d\\+\\)")[2]
        --
        --     local extra_args = {}
        --
        --     -- tells the formatter the filename for the code passed to it via stdin.
        --     -- This allows formatting heex files correctly. Only available for
        --     -- Elixir >= 1.14
        --     if tonumber(minor_version, 10) >= 14 then
        --       extra_args = { "--stdin-filename", "$FILENAME" }
        --     end
        --
        --     return extra_args
        --   end,
        -- }),
        b.formatting.gofmt,
        b.formatting.goimports,
        b.formatting.pg_format,
        b.formatting.prettierd.with({
          extra_filetypes = { "ruby" },
        }),
        b.formatting.shfmt,
        b.formatting.stylua,
      },
      on_attach = function(client)
        if client.supports_method("textDocument/formatting") then
          lsp_format.on_attach(client)
        end
      end,
    })
  end,
}
