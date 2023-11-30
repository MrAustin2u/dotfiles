local Utils = require("utils")

return {
  {
    "folke/flash.nvim",
    enabled = false,
  },
  -- Better NVIM UI
  { "MunifTanjim/nui.nvim", lazy = true },
  { "dressing.nvim" },
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
      }

      table.insert(opts.routes, {
        filter = {
          event = "notify",
          find = "No information available",
        },
        opts = { skip = true },
      })

      opts.presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
      }
    end,
  },
  -- A better vim.notify
  {
    "rcarriga/nvim-notify",
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Dismiss all Notifications",
      },
    },
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 })
      end,
      background_colour = "#000000",
    },
    init = function()
      -- when noice is not enabled, install notify on VeryLazy
      if not Utils.has("noice.nvim") then
        Utils.on_very_lazy(function()
          vim.notify = require("notify")
        end)
      end
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
  --
  -- Animations
  --
  {
    "echasnovski/mini.animate",
    event = "VeryLazy",
    opts = function()
      -- don't use animate when scrolling with the mouse
      local mouse_scrolled = false
      for _, scroll in ipairs({ "Up", "Down" }) do
        local key = "<ScrollWheel" .. scroll .. ">"
        vim.keymap.set({ "", "i" }, key, function()
          mouse_scrolled = true
          return key
        end, { expr = true })
      end

      local animate = require("mini.animate")
      return {
        resize = {
          timing = animate.gen_timing.linear({ duration = 100, unit = "total" }),
        },
        scroll = {
          timing = animate.gen_timing.linear({ duration = 150, unit = "total" }),
          subscroll = animate.gen_subscroll.equal({
            predicate = function(total_scroll)
              if mouse_scrolled then
                mouse_scrolled = false
                return false
              end
              return total_scroll > 1
            end,
          }),
        },
      }
    end,
  },
  { "nvimdev/dashboard-nvim",      enabled = false },
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
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = {
            {
              "diagnostics",
              symbols = {
                error = Utils.icons.diagnostics.Error,
                warn = Utils.icons.diagnostics.Warn,
                info = Utils.icons.diagnostics.Info,
                hint = Utils.icons.diagnostics.Hint,
              },
            },
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            { "filename", path = 1, symbols = { modified = "  ", readonly = "", unnamed = "" } },
          },
          lualine_x = {
            {
              require("lazy.status").updates,
              cond = require("lazy.status").has_updates,
              color = { bg = "none", fg = "#ff966c" },
            },
          },
          lualine_y = {
            { "progress", separator = " ",                  padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
          },
          lualine_z = {
            function()
              return " " .. os.date("%a %x %I:%M:%S %p")
            end,
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
