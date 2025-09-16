return {
  { "L3MON4D3/LuaSnip", keys = {} },
  {
    "saghen/blink.cmp",
    dependencies = {
      "rafamadriz/friendly-snippets",
      {
        "saghen/blink.compat",
        version = "*",
        lazy = true,
        opts = {},
      },
      {
        "supermaven-inc/supermaven-nvim",
        opts = {
          log_level = "off",
          disable_inline_completion = true, -- disables inline completion for use with cmp
          disable_keymaps = true,           -- disables built in keymaps for more manual control
          disable_native_completion = true, -- disable built-in completion
        },
      },
      {
        "huijiro/blink-cmp-supermaven",
      },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
      "mgalliou/blink-cmp-tmux",
    },
    version = "*",
    opts = {
      snippets = { preset = "luasnip" },
      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = "mono",
      },
      sources = {
        default = { "lsp", "path", "supermaven", "snippets", "lazydev", "buffer" },
        providers = {
          supermaven = {
            name = "supermaven",
            module = "blink-cmp-supermaven",
            async = true,
          },
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
          cmdline = {
            min_keyword_length = 2,
          },
        },
      },
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
      cmdline = {
        keymap = {
          -- recommended, as the default keymap will only show and select the next item
          ["<Tab>"] = { "show", "accept" },
        },
        completion = {
          menu = {
            draw = {
              columns = {
                { "kind_icon",        "label", gap = 1 },
                { "label_description" },
              },
            },
          },
        },
      },
      completion = {
        list = {
          selection = {
            preselect = false,
            auto_insert = true,
          },
        },
        menu = {
          auto_show = true,
          border = "rounded",
          draw = {
            components = {
              kind_icon = {
                ellipsis = false,
                text = function(ctx)
                  if ctx.kind == "Supermaven" then
                    return require("config.utils").icons.kinds.Copilot .. " "
                  end

                  local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                  return kind_icon
                end,
                highlight = function(ctx)
                  local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                  return hl
                end,
              },
              label = {
                text = function(ctx)
                  -- Fix for weird rendering in ElixirLS structs/behaviours etc
                  -- structs, behaviours and others have a label_detail emitted
                  -- by ElixirLS, and it looks bad when there's no space between
                  -- the module label and the label_detail.
                  --
                  -- The label_detail has no space because it is normally meant
                  -- for function signatures, e.g. `my_function(arg1, arg2)` -
                  -- this case the label is `my_function` and the label_detail
                  -- is `(arg1, arg2)`.
                  --
                  -- In an ideal world ElixirLS would not emit them for these
                  -- types - these belong in `kind` only.
                  if ctx.item.client_name == "elixirls" and ctx.kind ~= "Function" and ctx.kind ~= "Macro" then
                    return ctx.label
                  end

                  return ctx.label .. ctx.label_detail
                end,
                highlight = "CmpItemAbbr",
              },
            },
            treesitter = { "lsp" },
            columns = {
              { "kind_icon",         "label", gap = 1 },
              { "label_description", gap = 1 },
              { "source_name" },
            },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 100,
          window = {
            -- for each of the possible menu window directions,
            -- falling back to the next direction when there's not enough space
            direction_priority = {
              menu_north = { "e", "w", "n", "s" },
              menu_south = { "e", "w", "s", "n" },
            },
          },
        },
      },
      opts_extend = { "sources.default" },
    },
  },
}
