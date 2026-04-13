-- Available formatters: https://github.com/stevearc/conform.nvim#formatters

-- Check if config files exist, searching upward from `path` (defaults to cwd)
local function has_config(files, path)
  local root = vim.fs.find({ ".git", "package.json" }, { upward = true, path = path })[1]
  local config_files = vim.fs.find(files, {
    upward = true,
    path = path,
    type = "file",
    stop = root and vim.fs.dirname(root) or nil,
  })
  return #config_files > 0
end

-- Use prettier as the fallback (removed dprint)
local prettier_fallback = { "prettierd", "prettier", stop_after_first = true }

-- Evaluate biome vs prettier per-buffer so switching projects picks up the
-- correct formatter without restarting Neovim.
local function biome_or_prettier(bufnr)
  local bufdir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":h")
  if has_config({ "biome.json", "biome.jsonc" }, bufdir) then
    return { "biome", "biome-check" }
  end
  return prettier_fallback
end

---@type LazySpec
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
      javascript = biome_or_prettier,
      javascriptreact = biome_or_prettier,
      typescript = biome_or_prettier,
      typescriptreact = biome_or_prettier,
      json = biome_or_prettier,
      jsonc = biome_or_prettier,
      css = biome_or_prettier,
      vue = biome_or_prettier,
      svelte = biome_or_prettier,
      astro = biome_or_prettier,
      graphql = biome_or_prettier,
      markdown = prettier_fallback,
      html = prettier_fallback,
      go = { "gofmt", "goimports" },
      ruby = { "rubyfmt" },
      sql = { "pg_format" },
      yaml = prettier_fallback,
      -- `mix format` has to cold-start the BEAM and (at PDQ) load
      -- elixir-styler, so 500ms is nowhere near enough. Override the
      -- default timeout for this filetype only.
      elixir = { "mix", timeout_ms = 5000 },
      sh = { "shfmt" },
      terraform = { "terraform_fmt" },
      toml = { "taplo" },
    },
    -- Set default options
    default_format_opts = {
      lsp_format = "fallback",
      timeout_ms = 500,
    },
    -- Set up format-on-save
    format_on_save = function(bufnr)
      -- Disable with a global or buffer-local variable. Returning nil skips
      -- formatting entirely; returning an empty table would still trigger a
      -- format with default opts.
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return nil
      end

      return {}
    end,
    -- Customize formatters
    formatters = {
      shfmt = {
        prepend_args = { "-i", "2" },
      },
      mix = {
        -- NOTE: conform was running mix format from the current directory of
        -- the file, which prevented formatting from working in cases where
        -- there is a nested .formatter.exs file that refers to a dependency a
        -- few folders above. For example in Phoenix projects, the
        -- .formatter.exs is created in the priv/repo/migrations dir and it
        -- references :ecto_sql, which can not be found if mix format is run
        -- directly from the migrations dir.
        --
        -- The wrapper is required so `require("conform.util")` is deferred
        -- until the plugin is loaded. Previously this function dropped the
        -- `return`, making cwd always nil and forcing BEAM to re-boot in a
        -- deep subdirectory on every save.
        cwd = function(self, ctx)
          return (require("conform.util").root_file { "mix.exs" })(self, ctx)
        end,
      },
    },
  },
  config = function(_self, opts)
    local conform = require "conform"

    conform.setup(opts)

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
      conform.format { async = true }
    end, {
      desc = "Format file",
    })
  end,
}
