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
  --
  -- Bufferline
  --
  {
    "akinsho/bufferline.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>",            desc = "Toggle pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
    },
    opts = {
      options = {
        buffer_close_icon = "",
        -- stylua: ignore
        close_command = function(n) require("mini.bufremove").delete(n, false) end,
        always_show_bufferline = false,
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(_, _, diag)
          local icons = Utils.icons.diagnostics
          local ret = (diag.error and icons.Error .. diag.error .. " " or "")
              .. (diag.warning and icons.Warn .. diag.warning or "")
          return vim.trim(ret)
        end,
        offsets = {
          {
            filetype = "neo-tree",
            text = "Neo-tree",
            highlight = "Directory",
            text_align = "left",
          },
        },
        -- stylua: ignore
        right_mouse_command = function(n) require("mini.bufremove").delete(n, false) end
        ,
      },
    },
  },
}
