-- Available formatters: https://github.com/stevearc/conform.nvim#formatters

-- try prettierd, and fallback to prettier, if the first one works stop
local prettier = { "prettierd", "prettier", stop_after_first = true }

return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo", "Format", "FormatDisable", "FormatEnable" },
  -- This will provide type hinting with LuaLS
  ---@module "conform"
  ---@type conform.setupOpts
  opts = {
    -- Define your formatters
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "isort", "black" },
      javascript = prettier,
      javascriptreact = prettier,
      markdown = prettier,
      go = { "gofmt", "goimports" },
      sql = { "pg_format" },
      yaml = prettier,
      json = prettier,
      typescript = prettier,
      typescriptreact = prettier,
      sh = { "shfmt" },
      -- elixir = { "mix", timeout_ms = 2000 },
    },
    -- Set default options
    default_format_opts = {
      lsp_format = "fallback",
      timeout_ms = 500,
    },
    -- Set up format-on-save
    format_on_save = function(bufnr)
      -- Disable with a global or buffer-local variable
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end

      return { timeout_ms = 500, lsp_format = "fallback" }
    end,
    -- Customize formatters
    formatters = {
      shfmt = {
        prepend_args = { "-i", "2" },
      },
      -- mix = {
      --   -- NOTE: conform was running mix format from the current directory of
      --   -- the file, which prevented formatting from working in cases where
      --   -- there is a nested .formatter.exs file that refers to a dependency a
      --   -- few folders above. For example in Phoenix projects, the
      --   -- .formatter.exs is created in the priv/repo/migrations dir and it
      --   -- references :ecto_sql, which can not be found if mix format is run
      --   -- directly from the migrations dir
      --   cwd = function(self, ctx)
      --     (require("conform.util").root_file { "mix.exs" })(self, ctx)
      --   end,
      -- },
    },
  },
  init = function()
    -- If you want the formatexpr, here is the place to set it
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

    vim.api.nvim_create_user_command("FormatDisable", function(args)
      if args.bang then
        -- FormatDisable! will disable formatting just for this buffer
        vim.b.disable_autoformat = true
      else
        vim.g.disable_autoformat = true
      end
    end, {
      desc = "Disable autoformat-on-save",
      bang = true,
    })

    vim.api.nvim_create_user_command("FormatEnable", function()
      vim.b.disable_autoformat = false
      vim.g.disable_autoformat = false
    end, {
      desc = "Re-enable autoformat-on-save",
    })

    vim.api.nvim_create_user_command("Format", function()
      require("conform").format { async = true }
    end, {
      desc = "Format file",
    })
  end,
}
