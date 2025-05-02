return {
  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    dependencies = {
      { "L3MON4D3/LuaSnip",                     version = "v2.*" },
      "echasnovski/mini.icons",
      "rafamadriz/friendly-snippets",
      "onsails/lspkind.nvim",
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true }, -- Optional
      {
        "saghen/blink.compat",
        opts = {},
        version = "*",
      },
    },
    version = "*",
    opts = {
      snippets = {
        preset = "luasnip",
        -- expand = function(snippet, _)
        --   return aa.cmp.expand(snippet)
        -- end,
      },
      keymap = {
        preset = "super-tab",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },

        ["<CR>"] = {
          "accept",
          "fallback",
        },

        ["<Tab>"] = {
          function(cmp)
            return cmp.select_next()
          end,
          "snippet_forward",
          "fallback",
        },
        ["<S-Tab>"] = {
          function(cmp)
            return cmp.select_prev()
          end,
          "snippet_backward",
          "fallback",
        },

        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-up>"] = { "scroll_documentation_up", "fallback" },
        ["<C-down>"] = { "scroll_documentation_down", "fallback" },
      },

      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = "mono",
      },

      completion = {
        accept = { auto_brackets = { enabled = true } },

        documentation = {
          auto_show = true,
          auto_show_delay_ms = 250,
          treesitter_highlighting = true,
          window = { border = "rounded" },
        },

        list = {
          selection = {
            preselect = function(ctx)
              return ctx.mode == "cmdline" and "auto_insert" or "preselect"
            end,
          },
        },

        menu = {
          border = "rounded",
          cmdline_position = function()
            if vim.g.ui_cmdline_pos ~= nil then
              local pos = vim.g.ui_cmdline_pos -- (1, 0)-indexed
              return { pos[1] - 1, pos[2] }
            end
            local height = (vim.o.cmdheight == 0) and 1 or vim.o.cmdheight
            return { vim.o.lines - height, 0 }
          end,
          draw = {
            columns = {
              { "kind_icon", "label", gap = 1 },
              { "kind" },
            },
            components = {
              kind_icon = {
                ellipsis = false,
                text = function(ctx)
                  if ctx.kind == "Copilot" then
                    return aa.icons.kinds.Copilot .. " "
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
                  return ctx.label
                end,
                highlight = "CmpItemAbbr",
              },
              kind = {
                text = function(ctx)
                  return ctx.kind
                end,
                highlight = "CmpItemKind",
              },
            },
          },
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
          border = "rounded",
        },
      },

      -- opts_extend = { "sources.default" },
      sources = {
        default = {
          "supermaven",
          "lsp",
          "path",
          "snippets",
          "buffer",
          "lazydev",
          "obsidian",
          "obsidian_new",
          "obsidian_tags",
          "dadbod",
        },
        providers = {
          supermaven = {
            name = "supermaven",
            module = "blink.compat.source",
            score_offset = 1,
            transform_items = function(ctx, items)
              local kind = "Supermaven"
              require("blink.cmp.types").CompletionItemKind[kind] = kind
              for i, _ in ipairs(items) do
                items[i].kind = kind
              end
              return items
            end,
          },
          buffer = {
            min_keyword_length = 5,
            max_items = 5,
          },
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            -- make lazydev completions top priority (see `:h blink.cmp`)
            score_offset = 100,
          },
          lsp = {
            min_keyword_length = 1, -- Number of characters to trigger provider
            score_offset = 0,       -- Boost/penalize the score of the items
          },
          path = {
            min_keyword_length = 0,
          },
          snippets = {
            min_keyword_length = 1,
          },
          obsidian = {
            name = "obsidian",
            module = "blink.compat.source",
          },
          obsidian_new = {
            name = "obsidian_new",
            module = "blink.compat.source",
          },
          obsidian_tags = {
            name = "obsidian_tags",
            module = "blink.compat.source",
          },
          dadbod = {
            name = "Dadbod",
            module = "vim_dadbod_completion.blink",
          },
        },
      },
    },
    opts_extend = {
      "sources.completion.enabled_providers",
      "sources.compat",
      "sources.default",
    },
  },
  -- add icons
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.appearance = opts.appearance or {}
      opts.appearance.kind_icons = vim.tbl_extend("force", opts.appearance.kind_icons or {}, aa.icons.kinds)
    end,
  },
}
