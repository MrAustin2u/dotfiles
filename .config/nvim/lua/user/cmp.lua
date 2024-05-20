local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local tmux_source = {
  name = 'tmux',
  option = { all_panes = true },
}

local all_buffers_completion_source = {
  name = 'buffer',
  option = {
    get_bufnrs = function()
      -- complete from all buffers
      return vim.api.nvim_list_bufs()
    end,
  },
}

local M = {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    {
      "hrsh7th/cmp-nvim-lsp",
      event = "InsertEnter",
    },
    {
      "hrsh7th/cmp-emoji",
      event = "InsertEnter",
    },
    {
      "hrsh7th/cmp-buffer",
      event = "InsertEnter",
    },
    {
      "hrsh7th/cmp-path",
      event = "InsertEnter",
    },
    {
      "hrsh7th/cmp-cmdline",
      event = "InsertEnter",
    },
    {
      "saadparwaiz1/cmp_luasnip",
      event = "InsertEnter",
    },
    {
      'petertriho/cmp-git',
      event = "InsertEnter",

    },
    {
      'andersevenrud/cmp-tmux',
      event = "InsertEnter"
    },
    {
      "L3MON4D3/LuaSnip",
      event = "InsertEnter",
      dependencies = {
        "rafamadriz/friendly-snippets",
      },
    },
    {
      "hrsh7th/cmp-nvim-lua",
      event = "InsertEnter",
    },
    { "roobert/tailwindcss-colorizer-cmp.nvim", config = true },
    {
      'saecki/crates.nvim',
      tag = 'stable',
      config = function(_, opts)
        require('crates').setup(opts)
      end,
    }
  },
  opts = function(_, _)
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    -- local defaults = require("cmp.config.default")()
    local icons = require("config.icons")
    require("luasnip/loaders/from_vscode").lazy_load()

    vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
    vim.api.nvim_set_hl(0, "CmpItemKindEmoji", { fg = "#FDE030" })



    local opts = {
      window = {
        border = "rounded",
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      completion = {
        completeopt = "menu,menuone,noinsert",
      },
      mapping = {
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
            -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
            -- this way you will only jump inside the snippet region
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
      },
      sources = cmp.config.sources({
        { name = "copilot" },
        { name = "nvim_lsp" },
        { name = "nvim_lsp_signature_help" },
        { name = "nvim_lua" },
        { name = "luasnip" },
        { name = "path" },
        all_buffers_completion_source,
        { name = "calc" },
        { name = "emoji" },
        tmux_source,
        { name = "crates" },
      }),
      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
          vim_item.kind = icons.kind[vim_item.kind]

          if entry.source.name == "emoji" then
            vim_item.kind = icons.misc.Smiley
            vim_item.kind_hl_group = "CmpItemKindEmoji"
          end

          -- find icon based on kind
          -- Source
          local source = ({
            buffer = '[BUF]',
            cmdline = '[CMD]',
            copilot = '[COP]',
            emoji = '[EMJ]',
            luasnip = '[SNP]',
            nvim_lsp = '[LSP]',
            nvim_lua = '[LUA]',
            path = '[PTH]',
            tmux = '[TMX]'
          })[entry.source.name]

          vim_item.menu = string.format('%s', source)

          return vim_item
        end,
      },
      preselect = cmp.PreselectMode.None,
      -- sorting = defaults.sorting,
    }

    local format_kinds = opts.formatting.format
    opts.formatting.format = function(entry, item)
      format_kinds(entry, item) -- add icons
      return require("tailwindcss-colorizer-cmp").formatter(entry, item)
    end
    return opts
  end,
}

function M.config(_, opts)
  local cmp = require("cmp")
  cmp.setup(opts)

  -- completion for neovim lua configs
  cmp.setup.filetype('lua', {
    sources = cmp.config.sources({
      { name = 'nvim_lua' },
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'path' },
    }, {
      all_buffers_completion_source,
      tmux_source,
    }),
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'git' }, -- `cmp_git`
    }, {
      all_buffers_completion_source,
      tmux_source,
      { name = 'emoji' },
    }),
  })

  -- Use buffer source for `/`
  -- (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' },
    },
  })
end

return M
