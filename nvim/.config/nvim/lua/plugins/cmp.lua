return {
  "hrsh7th/nvim-cmp",
  version = false, -- last release is way too old
  event = "InsertEnter",
  dependencies = {
    {
      "L3MON4D3/LuaSnip",
      dependencies = {
        "rafamadriz/friendly-snippets",
      },
    },
    "andersevenrud/cmp-tmux",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-nvim-lsp-signature-help",
    "hrsh7th/cmp-nvim-lua",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-vsnip",
    "hrsh7th/vim-vsnip",
    "onsails/lspkind.nvim",
    "petertriho/cmp-git",
    "saadparwaiz1/cmp_luasnip",
  },
  config = function()
    vim.g.vsnip_snippet_dir = "~/.config/nvim/snippets"

    local cmp = require("cmp")
    local lspkind = require("lspkind")
    local luasnip = require("luasnip")

    local has_words_before = function()
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end

    local tmux_source = {
      name = "tmux",
      option = { all_panes = true },
    }

    local all_buffers_completion_source = {
      name = "buffer",
      option = {
        get_bufnrs = function()
          -- complete from all buffers
          return vim.api.nvim_list_bufs()
        end,
      },
    }

    local opts = {
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      completion = {
        completeopt = "menu,menuone,noinsert",
      },
      snippet = {
        expand = function(args)
          vim.fn["vsnip#anonymous"](args.body)
        end,
        -- expand = function(args)
        --   luasnip.lsp_expand(args.body)
        -- end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ["<S-CR>"] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "path" },
        all_buffers_completion_source,
        { name = "emoji" },
        tmux_source,
      }),
      preselect = cmp.PreselectMode.None,
      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = lspkind.cmp_format({
          symbol_map = { Copilot = "" },
          -- mode = "symbol", -- show only symbol annotations
          maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
          ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
          before = function(entry, vim_item)
            local source = ({
              buffer = "[BUF]",
              cmdline = "[CMD]",
              emoji = "[EMJ]",
              git = "[GIT]",
              luasnip = "[SNP]",
              nvim_lsp = vim_item.kind,
              nvim_lua = "[LUA]",
              path = "[PTH]",
              tmux = "[TMX]",
            })[entry.source.name]

            local padded_kind = require("utils").right_pad(vim_item.kind, 8, " ")
            vim_item.menu = string.format("%s %s", padded_kind, source)

            return vim_item
          end,
        }),
      },
      experimental = {
        ghost_text = {
          hl_group = "LspCodeLens",
        },
      },
    }

    cmp.setup(opts)
  end,
}
