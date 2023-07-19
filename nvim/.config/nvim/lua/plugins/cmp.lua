-- Setup nvim-cmp.
local cmp_present, cmp = pcall(require, "cmp")
local luasnip_present, luasnip = pcall(require, "luasnip")
local lspkind_present, lspkind = pcall(require, "lspkind")

if not cmp_present or not luasnip_present or not lspkind_present then
  return false
end

if not cmp then
  return false
end

local M = {}

M.setup = function()
  vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
  local defaults = require("cmp.config.default")()

  luasnip.config.setup()

  local opts = {
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    formatting = {
      fields = { "kind", "abbr", "menu" },
      format = lspkind.cmp_format({
        mode = "symbol_text", -- show only symbol annotations
        maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
        ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)

        preset = "codicons",

        -- The function below will be called before any actual modifications from lspkind
        -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
        before = function(entry, vim_item)
          -- find icon based on kind
          -- Source
          local source = ({
            buffer = "[BUF]",
            cmdline = "[CMD]",
            luasnip = "[SNP]",
            nvim_lsp = "[LSP]",
            nvim_lua = "[LUA]",
            path = "[PTH]",
          })[entry.source.name]

          vim_item.menu = string.format("%s", source)

          return vim_item
        end,
      }),
    },
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-n>"] = cmp.mapping.select_next_item(),
      ["<C-p>"] = cmp.mapping.select_prev_item(),
      ["<C-d>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete({}),
      ["<CR>"] = cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Replace,
        select = true,
      }),
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_locally_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.locally_jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
    }),
    sources = {
      { name = "buffer" },
      { name = "cmdline" },
      { name = "copilot" },
      { name = "luasnip" },
      { name = "nvim_lsp" },
      { name = "path" },
    },
    sorting = defaults.sorting,
    experimental = {
      ghost_text = {
        hl_group = "CmpGhostText",
      },
    },
  }

  cmp.setup(opts)

  require("luasnip.loaders.from_vscode").lazy_load()
end

return M
