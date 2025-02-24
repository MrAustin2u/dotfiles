return {
  {
    "hrsh7th/nvim-cmp",
    enabled = false,
  },
  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    dependencies = {
      "rafamadriz/friendly-snippets",
      "onsails/lspkind.nvim",
      "giuxtaposition/blink-cmp-copilot",
      {
        "saghen/blink.compat",
        opts = {},
        version = "*",
      },
    },
    version = "*",
    opts_extend = {
      "sources.completion.enabled_providers",
      "sources.compat",
      "sources.default",
    },
    opts = {
      snippets = {
        expand = function(snippet, _)
          return aa.cmp.expand(snippet)
        end,
      },
      -- keymap = { preset = "default" },
      keymap = {
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<CR>"] = { "accept", "fallback" },

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
                text = function(item)
                  if item.kind == "Copilot" then
                    return aa.icons.kind.Copilot .. " "
                  end

                  local kind = aa.icons.kind[item.kind] or ""
                  return kind .. " "
                end,
                highlight = "CmpItemKind",
              },
              label = {
                text = function(item)
                  return item.label
                end,
                highlight = "CmpItemAbbr",
              },
              kind = {
                text = function(item)
                  return item.kind
                end,
                highlight = "CmpItemKind",
              },
            },
          },
        },
      },

      signature = {
        enabled = true,
        window = { border = "rounded" },
      },

      -- opts_extend = { "sources.default" },
      sources = {
        default = {
          "buffer",
          "copilot",
          "dadbod",
          "lazydev",
          "lsp",
          "path",
          "snippets",
        },
        providers = {
          buffer = {
            min_keyword_length = 5,
            max_items = 5,
          },
          copilot = {
            name = "copilot",
            module = "blink-cmp-copilot",
            score_offset = 100,
            async = true,
            transform_items = function(_, items)
              local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
              local kind_idx = #CompletionItemKind + 1
              CompletionItemKind[kind_idx] = "Copilot"
              for _, item in ipairs(items) do
                item.kind = kind_idx
              end
              return items
            end,
          },
          dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
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
            opts = {
              search_paths = { "~/.config/nvim/lua/snippets" },
            },
          },
        },
      },
    },
  },
  -- add icons
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.appearance = opts.appearance or {}
      opts.appearance.kind_icons = vim.tbl_extend("force", opts.appearance.kind_icons or {}, aa.icons.kind)
    end,
  },
}
