-- Setup nvim-cmp.
local cmp_present, cmp = pcall(require, "cmp")
local lspkind_present, lspkind = pcall(require, "lspkind")

if not cmp_present or not lspkind_present then
  return false
end

if not cmp then
  return false
end

local M = {}

M.setup = function()
  vim.g.vsnip_snippet_dir = "~/.config/nvim/snippets"

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
        vim.fn["vsnip#anonymous"](args.body)
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
      {
        name = "buffer",
        option = {
          get_bufnrs = function()
            return vim.api.nvim_list_bufs()
          end,
        },
      },
      { name = "cmdline" },
      { name = "copilot" },
      { name = "nvim_lsp" },
      { name = "nvim_lsp_signature_help" },
      { name = "nvim_lua" },
      { name = "path" },
      { name = "tmux" },
      { name = "vsnip" },
    },
  }

  cmp.setup(opts)

  local vsnip_opts = { remap = true, expr = true, replace_keycodes = false }
  vim.keymap.set({ "i", "s" }, "<Tab>", "vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)'      : '<Tab>'", vsnip_opts)
  vim.keymap.set({ "i", "s" }, "<S-Tab>", "vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'", vsnip_opts)
end

return M
