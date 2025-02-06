return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        elixirls = {
          keys = {
            {
              "<leader>tp",
              function()
                local params = vim.lsp.util.make_position_params()
                aa.lsp.execute {
                  command = "manipulatePipes:serverid",
                  arguments = { "toPipe", params.textDocument.uri, params.position.line, params.position.character },
                }
              end,
              desc = "To Pipe",
            },
            {
              "<leader>fp",
              function()
                local params = vim.lsp.util.make_position_params()
                aa.lsp.execute {
                  command = "manipulatePipes:serverid",
                  arguments = { "fromPipe", params.textDocument.uri, params.position.line, params.position.character },
                }
              end,
              desc = "From Pipe",
            },
          },
        },
        gleam = {},
        lexical = {
          cmd = { "/Users/aaustin/.local/share/nvim/mason/packages/lexical/libexec/lexical/bin/start_lexical.sh" },
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "elixir", "heex", "eex" })
      vim.treesitter.language.register("markdown", "livebook")
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local nls = require "null-ls"
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.diagnostics.credo.with {
          condition = function(utils)
            return utils.root_has_file ".credo.exs"
          end,
        },
      })
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    optional = true,
    ft = function(_, ft)
      vim.list_extend(ft, { "livebook" })
    end,
  },
}
