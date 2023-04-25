-- Setup nvim-cmp.
local cmp_present, cmp = pcall(require, "cmp")
local luasnip_present, luasnip = pcall(require, "luasnip")

if not cmp_present or not luasnip_present then
  return false
end

if not cmp then
  return false
end

local M = {}

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local cmp_opts = {
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  formatting = {
    fields = { "kind", "abbr", "menu" },
    format = function(entry, vim_item)
      local lspkind_icons = {
        Text = "",
        Method = "",
        Function = "",
        Constructor = " ",
        Field = "",
        Variable = "",
        Class = "",
        Interface = "",
        Module = "硫",
        Property = "",
        Unit = " ",
        Value = "",
        Enum = " ",
        Keyword = "ﱃ",
        Snippet = " ",
        Color = " ",
        File = " ",
        Reference = "Ꮢ",
        Folder = " ",
        EnumMember = " ",
        Constant = " ",
        Struct = " ",
        Event = "",
        Operator = "",
        TypeParameter = " ",
        Copilot = "",
      }
      local meta_type = vim_item.kind
      -- load lspkind icons
      vim_item.kind = lspkind_icons[vim_item.kind] .. ""

      vim_item.menu = ({
        buffer = " Buffer",
        nvim_lsp = meta_type,
        path = " Path",
        luasnip = " LuaSnip",
      })[entry.source.name]

      return vim_item
    end,
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
    -- Accept currently selected item. Set `select` to `false` to only
    -- confirm explicitly selected items.
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,
    }),
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
    ["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
    ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
  },
  sources = {
    { name = "copilot" },
    { name = "nvim_lsp" },
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

M.setup = function()
  vim.g.vsnip_snippet_dir = "~/.config/nvim/snippets"

  cmp.setup(cmp_opts)

  local opts = { remap = true, expr = true, replace_keycodes = false }
  -- vim.keymap.set({'i','s'}, '<C-J>',   "vsnip#expandable() ? '<Plug>(vsnip-expand)'         : '<C-J>'",   opts)
  -- vim.keymap.set({'i','s'}, '<C-L>',   "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-L>'",   opts)
  vim.keymap.set({ "i", "s" }, "<Tab>", "vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)'      : '<Tab>'", opts)
  vim.keymap.set({ "i", "s" }, "<S-Tab>", "vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'", opts)
end

return M
