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
    mapping = {
      ["<C-d>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-y>"] = cmp.mapping.close(),
      ["<C-c>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
      ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
      ["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
      ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
    },
    sources = {
      { name = "copilot" },
      { name = "nvim_lsp" },
      { name = "nvim_lsp_signature_help" },
      { name = "nvim_lua" },
      { name = "vsnip" },
      { name = "path" },
      { name = "tmux" },
      {
        name = "buffer",
        option = {
          get_bufnrs = function()
            return vim.api.nvim_list_bufs()
          end,
        },
      },
    },
  }

  cmp.setup(opts)

  local keymap_opts = { remap = true, expr = true, replace_keycodes = false }
  -- vim.keymap.set({'i','s'}, '<C-J>',   "vsnip#expandable() ? '<Plug>(vsnip-expand)'         : '<C-J>'",   opts)
  -- vim.keymap.set({'i','s'}, '<C-L>',   "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-L>'",   opts)
  vim.keymap.set({ "i", "s" }, "<Tab>", "vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)'      : '<Tab>'", keymap_opts)
  vim.keymap.set(
    { "i", "s" },
    "<S-Tab>",
    "vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'",
    keymap_opts
  )
end

return M
