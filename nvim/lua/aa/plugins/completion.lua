local cmp = require("cmp")
local lspkind = require("lspkind")
local luasnip = require("luasnip")

-- luasnip setup
local function setup_luasnip()
  local types = require("luasnip.util.types")
  luasnip.config.set_config({
    history = false,
    updateevents = "TextChanged,TextChangedI",
    store_selection_keys = "<Tab>",
    ext_opts = {
      [types.insertNode] = {
        passive = {
          hl_group = "Substitute",
        },
      },
      [types.choiceNode] = {
        active = {
          virt_text = { { "choiceNode", "IncSearch" } },
        },
      },
    },
    enable_autosnippets = true,
  })
  require("luasnip/loaders/from_vscode").lazy_load()
end

-- cmp setup
local function setup_cmp()
cmp.setup {
  enable_check_bracket_line = false,
  experimental = {
    ghost_text = false,
    native_menu = false, -- false == use fancy floaty menu for now
  },
  completion = {
    keyword_length = 3,
  },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end
  },
  documentation = {
    border = "rounded",
  },
  formatting = {
    format = lspkind.cmp_format({with_text = true, menu = ({
      nvim_lsp = "[LSP]",
      buffer = "[Buffer]",
      luasnip = "[LuaSnip]",
      path = "[Path]",
    })}),
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm { select = true },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end,{ "i", "s" }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end,{ "i", "s" }),
  },
  sources = {
    { name = 'nvim_lsp', max_item_count = 5 },
    { name = 'luasnip' ,
      option = {
        max_item_count = 5,
        keyword_length = 3,
        get_bufnrs = function()
          return vim.api.nvim_list_bufs()
        end,
      },
    },
    { name = 'buffer', max_item_count = 5 },
    { name = 'path', max_item_count = 5 },
  }
}

local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
end

setup_cmp()
setup_luasnip()
