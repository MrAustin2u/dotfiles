-- browse for anything using your choice of method
return {
  'lalitmee/browse.nvim',
  dependencies = { 'nvim-telescope/telescope.nvim' },
  config = function()
    local browse = require('browse')
    local command = function(name, rhs, opts)
      opts = opts or {}
      vim.api.nvim_create_user_command(name, rhs, opts)
    end

    browse.setup {
      provider = 'google',
      bookmarks = {
            ['github'] = {
              ['name'] = 'search github from neovim',
              ['code_search'] = 'https://github.com/search?q=%s&type=code',
              ['repo_search'] = 'https://github.com/search?q=%s&type=repositories',
              ['issues_search'] = 'https://github.com/search?q=%s&type=issues',
              ['pulls_search'] = 'https://github.com/search?q=%s&type=pullrequests',
        },
      },
    }

    command('InputSearch', function()
      browse.input_search()
    end, {})

    -- this will open telescope using dropdown theme with all the available options
    -- in which `browse.nvim` can be used
    command('Browse', function()
      browse.browse { bookmarks = bookmarks }
    end)

    command('Bookmarks', function()
      browse.open_bookmarks { bookmarks = bookmarks }
    end)

    command('DevdocsSearch', function()
      browse.devdocs.search()
    end)

    command('DevdocsFiletypeSearch', function()
      browse.devdocs.search_with_filetype()
    end)

    command('MdnSearch', function()
      browse.mdn.search()
    end)
  end,
}
