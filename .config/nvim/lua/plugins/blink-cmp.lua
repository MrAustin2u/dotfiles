---@type LazySpec
return {
  "saghen/blink.cmp",
  event = { "CmdlineEnter", "InsertEnter" },
  dependencies = {
    "rafamadriz/friendly-snippets",
    {
      "saghen/blink.compat",
      version = "*",
      lazy = true,
      opts = {},
    },
    "onsails/lspkind.nvim",
    { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true }, -- Optional
    "mgalliou/blink-cmp-tmux",
    "echasnovski/mini.icons",
  },

  -- use a release tag to download pre-built binaries
  version = "1.*",

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      preset = "super-tab",
      ["<C-Z>"] = { "accept", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
      ["<Tab>"] = {
        "select_next",
        "snippet_forward",
        function(cmp)
          if require("core.utils").has_words_before() or vim.api.nvim_get_mode().mode == "c" then
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

    appearance = {
      nerd_font_variant = "mono",
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
              { "kind_icon", "label", gap = 1 },
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
            { "kind_icon", "label", gap = 1 },
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
    signature = { enabled = true },
    -- ghost_text = { enabled = true },
    sources = {
      default = {
        "supermaven",
        "lsp",
        "path",
        "snippets",
        "buffer",
        "lazydev",
        "tmux",
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
        tmux = {
          enabled = function()
            return os.getenv "TMUX" ~= nil
          end,
          module = "blink-cmp-tmux",
          name = "tmux",
          -- default options
          opts = {
            all_panes = true,
            capture_history = true,
            -- only suggest completions from `tmux` if the `trigger_chars` are
            -- used
            triggered_only = true,
            trigger_chars = { ";" },
          },
        },
        snippets = {
          should_show_items = function(ctx)
            return ctx.trigger.initial_kind ~= "trigger_character"
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
          score_offset = 0, -- Boost/penalize the score of the items
        },
        path = {
          min_keyword_length = 0,
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

    -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
    -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
    -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
    --
    -- See the fuzzy documentation for more information
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" },
}
