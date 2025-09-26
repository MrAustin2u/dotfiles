return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    bufdelete = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('git_files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
        -- Used by the `header` section
        header = [[
        █████╗ ███████╗██╗  ██╗████████╗███████╗██╗  ██╗ █████╗
       ██╔══██╗██╔════╝██║  ██║╚══██╔══╝██╔════╝██║ ██╔╝██╔══██╗
       ███████║███████╗███████║   ██║   █████╗  █████╔╝ ███████║
       ██╔══██║╚════██║██╔══██║   ██║   ██╔══╝  ██╔═██╗ ██╔══██║
       ██║  ██║███████║██║  ██║   ██║   ███████╗██║  ██╗██║  ██║
       ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝
    ]],
      },
      sections = {
        { section = "header" },
        { section = "keys",   gap = 1, padding = 1 },
        { section = "startup" },
      },
    },
    explorer = { enabled = true },
    git = { enabled = true },
    indent = {
      enabled = true,
      animate = { enabled = false },
      -- this is what makes the scope look like an arrow
      chunk = { enabled = true },
    },
    input = { enabled = true },
    lazygit = { enabled = true },
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    picker = {
      enabled = true,
      win = {
        input = {
          keys = {
            ["<c-a>"] = false,
          },
        },
      },
      sources = {
        pr_files = {
          title = "PR Files",
          format = "text",
          finder = function(_opts, _ctx)
            -- TODO: make branch name dynamic based on the repo settings
            local output = vim.fn.systemlist "git diff --name-only origin/$(git rev-parse --abbrev-ref HEAD)"
            return vim.tbl_map(function(file)
              return {
                text = file,
                file = file,
                value = file,
              }
            end, output)
          end,
        },
        obsidian_vault = {
          title = "Obsidian Vault",
          format = "text",
          finder = function(_opts, _ctx)
            -- TODO: make branch name dynamic based on the repo settings
            local output = vim.fn.systemlist "vim ~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Ashteka"
            return vim.tbl_map(function(file)
              return {
                text = file,
                file = file,
                value = file,
              }
            end, output)
          end,
        },
      },
    },
    rename = { enabled = true },
    scope = { enabled = true },
    scratch = { enabled = true },
    statuscolumn = { enabled = true },
    styles = {
      notification = {
        wo = { wrap = true }, -- Wrap notifications
      },
      scratch = {
        width = 150,
        height = 60,
      },
    },
    terminal = {
      enabled = true,
      keys = {
        q = "hide",
        gf = function(self)
          local f = vim.fn.findfile(vim.fn.expand "<cfile>", "**")
          if f == "" then
            Snacks.notify.warn "No file under cursor"
          else
            self:hide()
            vim.schedule(function()
              vim.cmd("e " .. f)
            end)
          end
        end,
        term_normal = {
          "<esc>",
          function(self)
            self.esc_timer = self.esc_timer or (vim.uv or vim.loop).new_timer()
            if self.esc_timer:is_active() then
              self.esc_timer:stop()
              vim.cmd "stopinsert"
            else
              self.esc_timer:start(200, 0, function() end)
              return "<esc>"
            end
          end,
          mode = "t",
          expr = true,
          desc = "Double escape to normal mode",
        },
      },
    },
    words = { enabled = true },
  },
  keys = require("config.keymaps").snacks_mappings,
}
