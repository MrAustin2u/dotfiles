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
  local opts = {
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    formatting = {
      fields = { "kind", "abbr", "menu" },
      format = lspkind.cmp_format({
        symbol_map = { Copilot = "" },
        before = function(entry, vim_item)
          vim_item.menu = ({
            buffer = " Buffer",
            nvim_lsp = vim_item.kind,
            path = " Path",
            luasnip = " LuaSnip",
          })[entry.source.name]

          return vim_item
        end,
      }),
    },
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    sorting = defaults.sorting,
    mapping = {
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-c>"] = cmp.mapping.abort(),
      ["<C-d>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
      ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
      ["<C-y>"] = cmp.mapping.close(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
      ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
    },
    sources = {
      { name = "nvim_lua" },
      { name = "tmux" },
      { name = "vsnip" },
      { name = "buffer" },
      { name = "copilot", group_index = 2 },
      { name = "luasnip" },
      { name = "nvim_lsp" },
      -- { name = "nvim_lsp_signature_help" },
      { name = "path" },
    },
    experimental = {
      ghost_text = {
        hl_group = "CmpGhostText",
      },
    },
  }

  cmp.setup(opts)

  -- local keymap_opts = { remap = true, expr = true, replace_keycodes = false }
  -- vim.keymap.set({'i','s'}, '<C-J>',   "vsnip#expandable() ? '<Plug>(vsnip-expand)'         : '<C-J>'",   opts)
  -- vim.keymap.set({'i','s'}, '<C-L>',   "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-L>'",   opts)
  -- vim.keymap.set({ "i", "s" }, "<Tab>", "vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)'      : '<Tab>'", keymap_opts)
  -- vim.keymap.set(
  --   { "i", "s" },
  --   "<S-Tab>",
  --   "vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'",
  --   keymap_opts
  -- )
end

return M
