-- Setup nvim-cmp.
local cmp_present, cmp = pcall(require, 'cmp')
local luasnip_present, luasnip = pcall(require, 'luasnip')

if not cmp_present or not luasnip_present then
  return
end

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
end

local kind_icons = {
  Array = '',
  Boolean = '',
  Class = 'ﴯ',
  Color = '',
  Constant = '',
  Constructor = '',
  Enum = '',
  EnumMember = '',
  Event = '',
  Field = '',
  File = '',
  Folder = '',
  Function = '',
  Interface = '',
  Keyword = '',
  Method = '',
  Module = '',
  Object = 'פּ',
  Operator = '',
  Property = 'ﰠ',
  Reference = '',
  Snippet = '',
  Struct = '',
  Text = '',
  TypeParameter = '',
  Unit = '',
  Value = '',
  Variable = '',
}

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

local M = {}

M.setup = function()
  -- adds support for git completions
  require('cmp_git').setup {
    trigger_actions = {
      {
        debug_name = 'git_commits',
        trigger_character = '$',
        action = function(sources, trigger_char, callback, params, _)
          return sources.git:get_commits(callback, params, trigger_char)
        end,
      },
      {
        debug_name = 'github_issues_and_pr',
        trigger_character = '#',
        action = function(sources, trigger_char, callback, _, git_info)
          return sources.github:get_issues_and_prs(callback, git_info, trigger_char)
        end,
      },
      {
        debug_name = 'github_mentions',
        trigger_character = '@',
        action = function(sources, trigger_char, callback, _, git_info)
          return sources.github:get_mentions(callback, git_info, trigger_char)
        end,
      },
    },
  }

  cmp.setup {
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },

    formatting = {
      fields = { 'kind', 'abbr', 'menu' },
      format = function(entry, vim_item)
        -- find icon based on kind
        local icon = kind_icons[vim_item.kind]

        -- Source
        local source = ({
          buffer = '[B]',
          cmdline = '[C]',
          emoji = '[E]',
          git = '[G]',
          luasnip = '[S]',
          nvim_lsp = '[L]',
          nvim_lua = '[V]',
          path = '[P]',
          tmux = '[T]',
        })[entry.source.name]

        local padded_kind = require('core.utils').right_pad(vim_item.kind, 8, ' ')
        vim_item.menu = string.format('%s %s', padded_kind, source)
        vim_item.kind = icon

        return vim_item
      end,
    },

    mapping = cmp.mapping.preset.insert {
      ['<C-p>'] = cmp.mapping.select_prev_item(),
      ['<C-n>'] = cmp.mapping.select_next_item(),
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ---@diagnostic disable-next-line:missing-parameter
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),

      -- Accept currently selected item. Set `select` to `false` to only
      -- confirm explicitly selected items.
      ['<CR>'] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Replace,
        select = false,
      },

      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, { 'i', 's' }),

      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { 'i', 's' }),

      -- Snippet placeholder navigation to avoid conflict with tab completion
      ['<C-k>'] = cmp.mapping(function(fallback)
        if luasnip.jumpable(1) then
          luasnip.jump(1)
        else
          fallback()
        end
      end, { 'i' }),

      ['<C-j>'] = cmp.mapping(function(fallback)
        if luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { 'i' }),
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'path' },
    }, {
      all_buffers_completion_source,
      { name = 'emoji' },
      tmux_source,
    }),
    preselect = cmp.PreselectMode.None,
  }

  -- completion for neovim lua configs
  ---@diagnostic disable-next-line:undefined-field
  cmp.setup.filetype('lua', {
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'nvim_lua' },
      { name = 'path' },
    }, {
      all_buffers_completion_source,
      tmux_source,
    }),
  })

  -- Set configuration for specific filetype.
  ---@diagnostic disable-next-line:undefined-field
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

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' },
    }, {
      { name = 'cmdline', keyword_pattern = [=[[^[:blank:]%]*]=] },
    }),
  })

  luasnip.filetype_extend('typescriptreact', { 'react-ts', 'typescript', 'html' })
  luasnip.filetype_extend('javascriptreact', { 'react', 'javascript', 'html' })
  luasnip.filetype_extend('javascript', { 'react' })

  -- You can also use lazy loading so you only get in memory snippets of languages you use
  require('luasnip.loaders.from_vscode').lazy_load()
end

return M
