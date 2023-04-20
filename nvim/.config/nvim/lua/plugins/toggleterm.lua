local Utils = require("core.utils")
return {
  {
    "akinsho/toggleterm.nvim",
    event = "VeryLazy",
    version = "*",
    opts = {
      size = function(term)
        if term.direction == "horizontal" then
          return 20
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      autochdir = true,
      close_on_exit = true,
      direction = "vertical",
      float_opts = {
        border = "curved",
        hide_numbers = true,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
        insert_mappings = true,
        open_mapping = [[<C-\>]],
        persist_size = true,
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2,
        shell = vim.o.shell,
        start_in_insert = true,
        winblend = 0,
      },
    },
    config = function(_, toggle_term_opts)
      require("toggleterm").setup(toggle_term_opts)
      local Terminal = require("toggleterm.terminal").Terminal

      local open_handler = function(term)
        vim.cmd("startinsert!")
        vim.wo.sidescrolloff = 0
        if not Utils.falsy(vim.fn.mapcheck("jk", "t")) then
          vim.keymap.del("t", "jk", { buffer = term.bufnr })
          vim.keymap.del("t", "<esc>", { buffer = term.bufnr })
        end
      end

      -- terminal

      local terminal = Terminal:new({
        on_open = open_handler,
      })

      -- lazygit

      local lazygit = Terminal:new({
        cmd = "lazygit",
        dir = "git_dir",
        hidden = true,
        direction = "float",
        on_open = open_handler,
      })

      -- node
      local node = Terminal:new({ cmd = "node", direction = "vertical", hidden = true, on_open = open_handler })

      -- key maps
      function _G.set_terminal_keymaps()
        local opts = { noremap = true }
        vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], opts)
        vim.api.nvim_buf_set_keymap(0, "t", "jk", [[<C-\><C-n>]], opts)
        vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
        vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
        vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
        vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
      end

      vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
      vim.keymap.set({ "n", "t" }, "<C-\\>", function()
        terminal:toggle()
      end, { desc = "Toggleterm: toggle" })
      vim.keymap.set({ "n", "t" }, "<leader>gg", function()
        lazygit:toggle()
      end, { desc = "Toggleterm: toggle LazyGit" })
      vim.keymap.set({ "n", "t" }, "<C-n>", function()
        node:toggle()
      end, { desc = "Toggleterm: toggle Node" })
    end,
  },
}
