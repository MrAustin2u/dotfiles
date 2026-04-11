return {
  {
    "saghen/blink.compat",
    version = "*",
    lazy = true,
    opts = {
      impersonate_nvim_cmp = true,
    },
  },
  {
    "saghen/blink.cmp",
    dependencies = {
      "rafamadriz/friendly-snippets",
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
      "Exafunction/codeium.nvim",
    },
    version = "*",

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' for mappings similar to built-in completion
      -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
      -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
      -- See the full 'keymap' documentation for information on defining your own keymap.
      keymap = {
        preset = "super-tab",
        ["<C-Z>"] = { "accept", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = {
          "select_next",
          "snippet_forward",
          function(cmp)
            if require("config.utils").has_words_before() or vim.api.nvim_get_mode().mode == "c" then
              return cmp.show()
            end
          end,
          "fallback",
        },
        ["<S-Tab>"] = {
          "select_prev",
          "snippet_backward",
          function(cmp)
            if vim.api.nvim_get_mode().mode == "c" then
              return cmp.show()
            end
          end,
          "fallback",
        },
      },
      enabled = function()
        return vim.bo.buftype ~= "prompt"
          and vim.bo.buftype ~= "NvimTree"
          and vim.bo.buftype ~= "TelescopePrompt"
          and vim.bo.filetype ~= "DressingInput"
          and vim.b.completion ~= false
      end,
      signature = {
        enabled = true,
        window = {
          winblend = 0,
        },
      },
      completion = {
        documentation = {
          auto_show = true,
          window = {
            border = "rounded",
            winblend = 0,
          },
        },
        menu = {
          draw = {
            columns = { { "label", gap = 1 }, { "kind_icon", "kind" } },
            treesitter = { "lsp" },
          },
          border = "rounded",
          winblend = 0,
          winhighlight = "Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
        },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
        kind_icons = {
          Text = "󰉿 ",
          Method = "󰊕 ",
          Function = "󰊕 ",
          Constructor = "󰒓 ",

          Field = "󰜢 ",
          Variable = "󰆦 ",
          Property = "󰖷 ",

          Class = "󱡠 ",
          Interface = "󱡠 ",
          Struct = "󱡠 ",
          Module = "󰅩 ",

          Unit = "󰪚 ",
          Value = "󰦨 ",
          Enum = "󰦨 ",
          EnumMember = "󰦨 ",

          Keyword = "󰻾 ",
          Constant = "󰏿 ",

          Snippet = "󱄽 ",
          Color = "󰏘 ",
          File = "󰈔 ",
          Reference = "󰬲 ",
          Folder = "󰉋 ",
          Event = "󱐋 ",
          Operator = "󰪚 ",
          TypeParameter = "󰬛 ",

          Codeium = "",
        },
      },
      cmdline = {
        enabled = false,
        sources = function()
          return {}
        end,
      },
      sources = {
        default = {
          "codeium",
          "codecompanion",
          "lsp",
          "path",
          "snippets",
          "buffer",
          "dadbod",
        },
        providers = {
          codeium = { name = "Codeium", module = "codeium.blink", async = true },
          dadbod = {
            name = "Dadbod",
            module = "vim_dadbod_completion.blink",
          },
          codecompanion = {
            name = "codecompanion",
            module = "codecompanion.providers.completion.blink",
          },
        },
        per_filetype = {
          codecompanion = { "codecompanion" },
        },
      },
    },
    opts_extend = { "sources.default" },
  },
}
