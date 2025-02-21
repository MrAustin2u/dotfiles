-- try biome, prettierd, or prettier, and fallback to prettier, if the first one works stop
local biome_or_prettier = { 'biome', 'prettierd', 'prettier', stop_after_first = true }

return {
  "stevearc/conform.nvim",
  lazy = true,
  event = { "BufWritePre" },
  cmd = { 'ConformInfo', 'Format', 'FormatDisable', 'FormatEnable' },
  keys = {
    {
      "<leader>cF",
      function()
        require("conform").format { formatters = { "injected" }, timeout_ms = 3000 }
      end,
      mode = { "n", "v" },
      desc = "Format Injected Langs",
    },
  },
  init = function()
    -- Install the conform formatter on VeryLazy
    aa.on_very_lazy(function()
      aa.format.register {
        name = "conform.nvim",
        priority = 100,
        primary = true,
        format = function(buf)
          require("conform").format { bufnr = buf }
        end,
        sources = function(buf)
          local ret = require("conform").list_formatters(buf)
          ---@param v conform.FormatterInfo
          return vim.tbl_map(function(v)
            return v.name
          end, ret)
        end,
      }
    end)
  end,
  opts = function()
    local opts = {
      formatters_by_ft = {
        ["markdown.mdx"] = biome_or_prettier,
        ["terraform-vars"] = { "terraform_fmt" },
        go = { "goimports", "gofumpt" },
        graphql = biome_or_prettier,
        hcl = { "packer_fmt" },
        html = biome_or_prettier,
        javascript = biome_or_prettier,
        javascriptreact = biome_or_prettier,
        json = biome_or_prettier,
        lua = { 'stylua' },
        markdown = biome_or_prettier,
        python = { 'isort', 'black' },
        ruby = { 'rubyfmt', 'rubocop' },
        sh = { "shfmt" },
        sql = { "pg_format" },
        terraform = { "terraform_fmt" },
        tf = { "terraform_fmt" },
        typescript = biome_or_prettier,
        typescriptreact = biome_or_prettier,
        yaml = biome_or_prettier,
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback"
      },
      formatters = {
        biome = {
          require_cwd = true,
        },
        injected = { options = { ignore_errors = true } },
        ["markdown-toc"] = {
          condition = function(_, ctx)
            for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
              if line:find "<!%-%- toc %-%->" then
                return true
              end
            end
          end,
        },
        ["markdownlint-cli2"] = {
          condition = function(_, ctx)
            local diag = vim.tbl_filter(function(d)
              return d.source == "markdownlint"
            end, vim.diagnostic.get(ctx.buf))
            return #diag > 0
          end,
        },
        shfmt = {
          prepend_args = { "-i", "2" },
        },
      },
    }

    return opts
  end,
  config = function(_, opts)
    local conform = require("conform")
    conform.setup(opts)

    vim.api.nvim_create_user_command('FormatDisable', function(args)
      if args.bang then
        -- FormatDisable! will disable formatting just for this buffer
        vim.b.disable_autoformat = true
      else
        vim.g.disable_autoformat = true
      end
    end, {
      desc = 'Disable autoformat-on-save',
      bang = true,
    })

    vim.api.nvim_create_user_command('FormatEnable', function()
      vim.b.disable_autoformat = false
      vim.g.disable_autoformat = false
    end, {
      desc = 'Re-enable autoformat-on-save',
    })

    vim.api.nvim_create_user_command('Format', function()
      conform.format { async = true }
    end, {
      desc = 'Format file',
    })
  end,
}
