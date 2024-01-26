local Utils = require("utils")

return {
  {
    "folke/flash.nvim",
    enabled = false,
  },
  -- Better NVIM UI
  { "MunifTanjim/nui.nvim",        lazy = true },
  {
    "stevearc/dressing.nvim",
    config = function()
      require("dressing").setup {
        input = {
          override = function(conf)
            conf.col = -1
            conf.row = 0
            return conf
          end,
        }
      }
    end
  },
  --
  -- UI Messages
  --
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      opts.lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        hover = {
          enabled = false,
        },
      }

      opts.routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
        {
          filter = {
            event = 'lsp',
            kind = 'progress',
            cond = function(message)
              local title = vim.tbl_get(message.opts, 'progress', 'title')
              -- skip noisy messages
              return title == 'code_action'
            end,
          },
          opts = { skip = true },
        },
        {
          filter = {
            event = "notify",
            find = "No information available",
          },
          opts = { skip = true },
        }
      }


      opts.presets = {
        bottom_search = true,
        command_palette = true,
        inc_rename = true,
        long_message_to_split = true,
        lsp_doc_border = false,
      }
    end,
  },
  -- A better vim.notify
  {
    "rcarriga/nvim-notify",
    dependencies = {
      'stevearc/dressing.nvim',
    },
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Dismiss all Notifications",
      },
    },
    config = function()
      local notify = require('notify')
      notify.setup({
        background_colour = '#000000',
      })
      vim.notify = notify
      require('telescope').load_extension('notify')
    end,
  },
  --
  -- Icons
  --
  { "nvim-tree/nvim-web-devicons", lazy = true },

  --
  -- Indent
  --
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local ibl = require("ibl")

      ibl.setup({
        indent = { char = "│", tab_char = "│" },
        scope = {
          show_start = false,
          show_end = false,
          enabled = false,
        },
        exclude = {
          buftypes = { "NvimTree", "TelescopePrompt" },
          filetypes = {
            "alpha",
            "dashboard",
            "lazy",
            "lazyterm",
            "lspinfo",
            "man",
            "mason",
            "neo-tree",
            "notify",
            "qf",
          },
        },
      })
    end,
  },
  {
    "echasnovski/mini.indentscope",
    version = false, -- wait till new 0.7.0 release to put it back on semver
    opts = {
      -- symbol = "▏",
      symbol = "│",
      options = { try_as_border = true },
    },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },
  { "nvimdev/dashboard-nvim", enabled = false },
  {
    "echasnovski/mini.starter",
    enabled = true,
    version = false,
    opts = function()
      local logo = table.concat({
        "  █████╗ ███████╗██╗  ██╗████████╗███████╗██╗  ██╗ █████╗  ",
        " ██╔══██╗██╔════╝██║  ██║╚══██╔══╝██╔════╝██║ ██╔╝██╔══██╗ ",
        " ███████║███████╗███████║   ██║   █████╗  █████╔╝ ███████║ ",
        " ██╔══██║╚════██║██╔══██║   ██║   ██╔══╝  ██╔═██╗ ██╔══██║ ",
        " ██║  ██║███████║██║  ██║   ██║   ███████╗██║  ██╗██║  ██║ ",
        " ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ",
      }, "\n")
      local pad = string.rep(" ", 22)
      local new_section = function(name, action, section)
        return { name = name, action = action, section = pad .. section }
      end

      local starter = require("mini.starter")
      --stylua: ignore
      local config = {
        evaluate_single = true,
        header = logo,
        items = {
          new_section("Find file", "Telescope find_files", "Telescope"),
          new_section("Recent files", "Telescope oldfiles", "Telescope"),
          new_section("Grep text", "Telescope live_grep", "Telescope"),
          new_section("Lazy", "Lazy", "Config"),
          new_section("New file", "ene | startinsert", "Built-in"),
          new_section("Quit", "qa", "Built-in"),
        },
        content_hooks = {
          starter.gen_hook.adding_bullet(pad .. "░ ", false),
          starter.gen_hook.aligning("center", "center"),
        },
      }
      return config
    end,
  },
  -- LUALINE

  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          disabled_filetypes = {
            "TelescopePrompt",
            "TelescopeResults",
            statusline = { "dashboard", "alpha", "starter" }
          },
          component_separators = '|',
          section_separators = { left = '', right = '' },
          globalstatus = true,
        },
        sections = {
          lualine_a = {
            { 'mode', separator = { left = '' }, right_padding = 2 },
          },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { 'filename' },
          lualine_x = {
            {
              require("lazy.status").updates,
              cond = require("lazy.status").has_updates,
              color = { bg = "none", fg = "#ff966c" },
            },
          },
          lualine_y = { 'filetype', 'progress' },
          lualine_z = {
            { 'location', separator = { right = '' }, left_padding = 2 },
          },
        },
        extensions = { "neo-tree", "lazy" },
      })
    end,
  },
  -- COKELINE
  
  {
    'willothy/nvim-cokeline',
    lazy = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    keys = require("config.keymaps").cokeline_mappings(),
    config = function()
      local hlgroups = require("cokeline.hlgroups")
      local green = vim.g.terminal_color_2
      local errors_fg = hlgroups.get_hl_attr('DiagnosticError', 'fg')
      local warnings_fg = hlgroups.get_hl_attr('DiagnosticWarn', 'fg')
      local default_bg = '#444a73'
      local map = vim.api.nvim_set_keymap

      require('cokeline').setup({
        buffers = {
          new_buffers_position = 'next',
          filter_valid = function(buffer)
            return buffer.type ~= "terminal" and buffer.type ~= "quickfix"
          end
        },
        fill_hl = 'FloatBorder',
        default_hl = {
          fg = function(buffer)
            return buffer.is_focused
                and hlgroups.get_hl_attr('Normal', 'fg')
                or hlgroups.get_hl_attr('Comment', 'fg')
          end,
          bg = default_bg,
        },
        sidebar = {
          filetype = 'neo-tree',
          components = {
            {
              text = '  FileTree',
              style = 'bold',
              bg = 'none',
            },
          }
        },
        components = {
          {
            text = '',
            bg = 'none',
            fg = default_bg,
          },
          {
            text = function(buffer)
              return buffer.devicon.icon
            end,
            fg = function(buffer)
              return buffer.devicon.color
            end,
          },
          {
            text = ' ',
          },
          {
            text = function(buffer) return buffer.filename end,
            style = function(buffer)
              return buffer.is_focused and 'bold' or nil
            end,
          },
          {
            text = function(buffer)
              return (buffer.diagnostics.errors ~= 0 and '  ' .. buffer.diagnostics.errors)
                  or (buffer.diagnostics.warnings ~= 0 and ' ⚠ ' .. buffer.diagnostics.warnings)
                  or ''
            end,
            fg = function(buffer)
              return (buffer.diagnostics.errors ~= 0 and errors_fg)
                  or (buffer.diagnostics.warnings ~= 0 and warnings_fg)
                  or nil
            end,
            truncation = { priority = 1 },
          },
          {
            text = ' ',
          },
          {
            text = function(buffer)
              return buffer.is_modified and '●' or '󱎘'
            end,
            fg = function(buffer)
              return buffer.is_modified and green or nil
            end,
            delete_buffer_on_left_click = true,
            truncation = { priority = 1 },
          },
          {
            text = '',
            bg = 'none',
            fg = default_bg,
          },
          {
            text = ' ',
            bg = 'none',
          },
        },
      })

      for i = 1, 9 do
        map(
          "n",
          ("<Leader>%s"):format(i),
          ("<Plug>(cokeline-focus-%s)"):format(i),
          { silent = true }
        )
      end
    end
  }
}
