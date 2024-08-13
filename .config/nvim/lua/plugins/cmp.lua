return {
  "hrsh7th/nvim-cmp",
  keys = {
    {
      "<Tab>",
      "vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)'      : '<Tab>'",
      expr = true,
      remap = true,
      replace_keycodes = false,
      mode = { "i", "s" },
    },
    {
      "<S-Tab>",
      "vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'",
      expr = true,
      remap = true,
      replace_keycodes = false,
      mode = { "i", "s" },
    },
  },
  version = false, -- last release is way too old
  event = "InsertEnter",
  dependencies = {
    "andersevenrud/cmp-tmux",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-nvim-lsp-signature-help",
    "hrsh7th/cmp-nvim-lua",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-vsnip",
    "hrsh7th/vim-vsnip",
    "onsails/lspkind.nvim",
  },
  opts = function()
    local cmp = require "cmp"
    local lspkind = require "lspkind"
    local defaults = require "cmp.config.default"()
    local auto_select = true

    vim.g.vsnip_snippet_dir = "~/.config/nvim/snippets"
    vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
    vim.api.nvim_set_hl(0, "CmpItemKindSupermaven", { fg = "#6CC644" })

    return {
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      snippet = {
        expand = function(args)
          vim.fn["vsnip#anonymous"](args.body)
        end,
      },
      completion = {
        completeopt = "menu,menuone,noinsert" .. (auto_select and "" or ",noselect"),
      },
      preselect = auto_select and cmp.PreselectMode.Item or cmp.PreselectMode.None,
      mapping = {
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-y>"] = cmp.mapping.close(),
        ["<C-c>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm { select = false },
        ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
        ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
        ["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
        ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
      },
      sources = {
        { name = "supermaven" },
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
      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = lspkind.cmp_format {
          symbol_map = {
            Supermaven = "",
          },
          before = function(entry, vim_item)
            vim_item.menu = ({
              buffer = " Buffer",
              nvim_lsp = vim_item.kind,
              path = " Path",
              luasnip = " LuaSnip",
            })[entry.source.name]

            return vim_item
          end,
        },
      },
      sorting = defaults.sorting,
    }
  end,
}
