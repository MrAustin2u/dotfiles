local Utils = require("utils")

return {
  --
  -- MISC
  --
  { "tpope/vim-repeat", event = "VeryLazy" },
  --
  -- HTML support
  --
  "mattn/emmet-vim",
  --
  -- Graphql support
  --
  "jparise/vim-graphql",
  --
  -- Columns
  --
  "Bekaboo/deadcolumn.nvim",
  {
    "lukas-reineke/virt-column.nvim",
    config = function()
      require("virt-column").setup()
      vim.cmd([[ au VimEnter * highlight VirtColumn guifg=#1e2030 gui=nocombine ]])
    end,
  },
  --
  -- Snippets
  --
  {
    "L3MON4D3/LuaSnip",
    keys = function()
      return {}
    end,
  },
  {
    "rafamadriz/friendly-snippets",
    dependencies = { "L3MON4D3/LuaSnip" },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-emoji",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-nvim-lua",
      "lukas-reineke/cmp-under-comparator",
      "onsails/lspkind.nvim",
      { "roobert/tailwindcss-colorizer-cmp.nvim", config = true },
      {
        "Saecki/crates.nvim",
        event = { "BufRead Cargo.toml" },
        opts = {
          src = {
            cmp = { enabled = true },
          },
        },
      },
    },
    opts = function(_, opts)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local defaults = require("cmp.config.default")()
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")
      local cmp = require("cmp")

      local opts = {
        window = {
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
          {
            name = "buffer",
            option = {
              get_bufnrs = function()
                return vim.api.nvim_list_bufs()
              end,
            },
          },
          { name = "copilot" },
          { name = "crates" },
          { name = "luasnip" },
          { name = "nvim_lsp" },
          { name = "nvim_lsp_signature_help" },
          { name = "nvim_lua" },
          { name = "path" },
        }),
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
        sorting = defaults.sorting
      }

      local format_kinds = opts.formatting.format
      opts.formatting.format = function(entry, item)
        format_kinds(entry, item) -- add icons
        return require("tailwindcss-colorizer-cmp").formatter(entry, item)
      end
      return opts
    end,
  },
  --
  -- Copilot
  --
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        filetypes = { ["*"] = true },
        suggestion = { enabled = false },
        panel = { enabled = false },
      })
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "zbirenbaum/copilot.lua" },
    config = true,
  },
  --
  -- Comments
  --
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    opts = {
      enable_autocmd = false,
    },
  },
  {
    "echasnovski/mini.comment",
    event = "VeryLazy",
    opts = {
      options = {
        custom_commentstring = function()
          return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
        end,
      },
    },
  },
  --
  -- Finds and lists all of the TODO, HACK, BUG, etc comment
  -- in your project and loads them into a browsable list.
  --
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    config = true,
    -- stylua: ignore
    keys = {
      { "]t",         function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
      { "[t",         function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
      { "<leader>xt", "<cmd>TodoTrouble<cr>",                              desc = "Todo (Trouble)" },
      { "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>",      desc = "Todo/Fix/Fixme (Trouble)" },
      { "<leader>st", "<cmd>TodoTelescope<cr>",                            desc = "Todo" },
      { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>",    desc = "Todo/Fix/Fixme" },
    },
  },
  --
  -- Highlights
  --
  {
    "tzachar/local-highlight.nvim",
    config = function()
      vim.cmd([[hi TSDefinitionUsage guibg=#565f89]])

      require("local-highlight").setup()
    end,
  },
  {
    "kevinhwang91/nvim-hlslens",
    config = function()
      require("hlslens").setup()

      local opts = { noremap = true, silent = true }

      vim.api.nvim_set_keymap(
        "n",
        "n",
        [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
        opts
      )
      vim.api.nvim_set_keymap(
        "n",
        "N",
        [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
        opts
      )
      vim.api.nvim_set_keymap("n", "*", [[*<Cmd>lua require('hlslens').start()<CR>]], opts)
      vim.api.nvim_set_keymap("n", "#", [[#<Cmd>lua require('hlslens').start()<CR>]], opts)
      vim.api.nvim_set_keymap("n", "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], opts)
      vim.api.nvim_set_keymap("n", "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], opts)
    end,
  },
  --
  -- Auto pairs
  --
  {
    "echasnovski/mini.pairs",
    event = "VeryLazy",
    opts = {},
  },

  --
  -- Better text-objects
  --
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }, {}),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
        },
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)
      -- register all text objects with which-key
      Utils.on_load("which-key.nvim", function()
        ---@type table<string, string|table>
        local i = {
          [" "] = "Whitespace",
          ['"'] = 'Balanced "',
          ["'"] = "Balanced '",
          ["`"] = "Balanced `",
          ["("] = "Balanced (",
          [")"] = "Balanced ) including white-space",
          [">"] = "Balanced > including white-space",
          ["<lt>"] = "Balanced <",
          ["]"] = "Balanced ] including white-space",
          ["["] = "Balanced [",
          ["}"] = "Balanced } including white-space",
          ["{"] = "Balanced {",
          ["?"] = "User Prompt",
          _ = "Underscore",
          a = "Argument",
          b = "Balanced ), ], }",
          c = "Class",
          f = "Function",
          o = "Block, conditional, loop",
          q = "Quote `, \", '",
          t = "Tag",
        }
        local a = vim.deepcopy(i)
        for k, v in pairs(a) do
          a[k] = v:gsub(" including.*", "")
        end

        local ic = vim.deepcopy(i)
        local ac = vim.deepcopy(a)
        for key, name in pairs({ n = "Next", l = "Last" }) do
          i[key] = vim.tbl_extend("force", { name = "Inside " .. name .. " textobject" }, ic)
          a[key] = vim.tbl_extend("force", { name = "Around " .. name .. " textobject" }, ac)
        end
        require("which-key").register({
          mode = { "o", "x" },
          i = i,
          a = a,
        })
      end)
    end,
  },
  --
  -- DB
  --
  {
    "tpope/vim-dadbod",
    cmd = "DBUI",
    dependencies = {
      "tpope/vim-dotenv",
      "kristijanhusak/vim-dadbod-ui",
      "kristijanhusak/vim-dadbod-completion",
    },
    keys = {
      { "<leader>do", ":DBUI<CR><CR>",  desc = "Database UI Open" },
      { "<leader>dc", ":DBUIClose<CR>", desc = "Database UI Close" },
    },
    config = function()
      local cmp = require("cmp")

      vim.opt.cmdheight = 1
      vim.g.db_ui_show_help = 0
      vim.g.db_ui_win_position = "left"
      vim.g.db_ui_tmp_query_location = "~/Developer/queries"

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          cmp.setup.buffer(vim.tbl_extend("force", cmp.config.sources(), { { name = "vim-dadbod-completion" } }))
        end,
      })
    end,
  },
  --
  -- Screenshots
  --
  {
    "narutoxy/silicon.lua",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("silicon").setup({
        font = "MonoLisa",
        theme = "tokyonight_moon",
        bgColor = "#636da6",
      })
      require("config.keymaps").silicon_mappings()
    end,
  },
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      local octo = require("octo")

      octo.setup({
        default_remote = { "origin" },
      })

      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.markdown.filetype_to_parsername = "octo"
    end,
  },
  --
  -- Scratch files
  --
  {
    "m-demare/attempt.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local elixir_template = function()
        return [[
        defmodule Example do
          def run do
            IO.puts("Do stuff")
          end
        end
        ]]
      end

      local javascript_template = function()
        return [[
        const hello_world = "hello world!";
        const log = () => {
         console.log(hello_world)
        }
        ]]
      end

      local typescript_template = function()
        return [[
        const hello_world: string = "hello world!";
        const log = ():void => {
         console.log(hello_world)
        }
      ]]
      end

      local opts = {
        autosave = true,
        initial_content = {
          ex = elixir_template,
          js = javascript_template,
          ts = typescript_template,
        },
        ext_options = { "lua", "js", "ts", "ex", "yml", "" },
        format_opts = { [""] = "[None]", js = "JavaScript", lua = "Lua", ex = "Elixir", ts = "Typescript" },
        run = {
          ex = { "w", "!elixir %" },
        },
      }
      local attempt = require("attempt")
      attempt.setup(opts)

      require("config.keymaps").attempt_mappings(attempt)
    end,
  },
  --
  -- TEST
  --
  {
    "nvim-neotest/neotest",
    dependencies = {
      "jfpedroza/neotest-elixir",
      "nvim-neotest/neotest-go",
      "rouge8/neotest-rust",
      "nvim-neotest/neotest-python",
      "antoinemadec/FixCursorHold.nvim"
    },
    opts = {
      adapters = {
        ["neotest-rust"] = {},
        ["neotest-elixir"] = {},
        ["neotest-go"] = {},
        ["neotest-python"] = {},
      },
      status = { virtual_text = true },
      output = { open_on_run = true },
    },
    config = function(_, opts)
      local neotest = require("neotest")
      local neotest_ns = vim.api.nvim_create_namespace("neotest")
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            -- Replace newline and tab characters with space for more compact diagnostics
            local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
            return message
          end,
        },
      }, neotest_ns)

      if Utils.has("trouble.nvim") then
        opts.consumers = opts.consumers or {}
        -- Refresh and auto close trouble after running tests
        ---@type neotest.Consumer
        opts.consumers.trouble = function(client)
          client.listeners.results = function(adapter_id, results, partial)
            if partial then
              return
            end
            local tree = assert(client:get_position(nil, { adapter = adapter_id }))

            local failed = 0
            for pos_id, result in pairs(results) do
              if result.status == "failed" and tree:get_key(pos_id) then
                failed = failed + 1
              end
            end
            vim.schedule(function()
              local trouble = require("trouble")
              if trouble.is_open() then
                trouble.refresh()
                if failed == 0 then
                  trouble.close()
                end
              end
            end)
            return {}
          end
        end
      end

      if opts.adapters then
        local adapters = {}
        for name, config in pairs(opts.adapters or {}) do
          if type(name) == "number" then
            if type(config) == "string" then
              config = require(config)
            end
            adapters[#adapters + 1] = config
          elseif config ~= false then
            local adapter = require(name)
            if type(config) == "table" and not vim.tbl_isempty(config) then
              local meta = getmetatable(adapter)
              if adapter.setup then
                adapter.setup(config)
              elseif meta and meta.__call then
                adapter(config)
              else
                error("Adapter " .. name .. " does not support setup")
              end
            end
            adapters[#adapters + 1] = adapter
          end
        end
        opts.adapters = adapters
      end

      require("neotest").setup(opts)
      require("config.keymaps").neotest_mappings(neotest)
    end
  }
}
