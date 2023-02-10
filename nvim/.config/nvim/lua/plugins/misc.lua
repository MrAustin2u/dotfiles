return {
  {
    "andymass/vim-matchup",
    build = function()
      vim.g.loaded_matchit = 1
      vim.g.matchup_surround_enabled = true
      vim.g.matchup_matchparen_deferred = true
      vim.g.matchup_matchparen_offscreen = {
        method = "popup",
        fullwidth = true,
        highlight = "Normal",
        border = "shadow",
      }
    end,
  },
  {
    "zakharykaplan/nvim-retrail",
    opts = {
      -- Highlight group to use for trailing whitespace.
      hlgroup = "IncSearch",
      -- Enabled filetypes.
      filetype = {
        -- Excluded filetype list. Overrides `include` list.
        exclude = {
          "",
          "TelescopePrompt",
          "Trouble",
          "WhichKey",
          "alpha",
          "checkhealth",
          "diff",
          "fugitive",
          "fzf",
          "git",
          "gitcommit",
          "help",
          "lspinfo",
          "lspsagafinder",
          "lspsagaoutline",
          "man",
          "markdown",
          "mason",
          "null-ls-info",
          "qf",
          "unite",
          "neotree",
        },
      },
    },
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
    },
    -- stylua: ignore
    keys = {
      { "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
      { "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
      { "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice History" },
      { "<leader>sna", function() require("noice").cmd("all") end, desc = "Noice All" },
      { "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, silent = true, expr = true, desc = "Scroll forward", mode = {"i", "n", "s"} },
      { "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true, expr = true, desc = "Scroll backward", mode = {"i", "n", "s"}},
    },
  },
}
