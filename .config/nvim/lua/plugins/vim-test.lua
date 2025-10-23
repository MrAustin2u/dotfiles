return {
  "vim-test/vim-test",
  keys = require("config.keymaps").vim_test_mappings(),
  dependencies = {
    {
      "preservim/vimux",
      keys = {
        { "<leader>ro", "<CMD>VimuxOpenRunner<CR>", desc = "open/create the runner" },
        { "<leader>rr", "<CMD>VimuxPromptCommand<CR>", desc = "run a command (prompt)" },
        { "<leader>r.", "<CMD>VimuxRunLastCommand<CR>", desc = "run the last run command" },
        { "<leader>rc", "<CMD>VimuxClearTerminalScreen<CR>", desc = "clear the current run terminal" },
        { "<leader>rq", "<CMD>VimuxCloseRunner<CR>", desc = "close the runner" },
        { "<leader>r?", "<CMD>VimuxInspectRunner<CR>", desc = "inspect the runner" },
        { "<leader>r!", "<CMD>VimuxInterruptRunner<CR>", desc = "interrupt the runner (bang'er)" },
        { "<leader>rz", "<CMD>VimuxZoomRunner<CR>", desc = "zoom the runner" },
        {
          "<C-c><C-c>",
          function()
            -- yank text into v register
            if vim.api.nvim_get_mode()["mode"] == "n" then
              vim.cmd 'normal vip"vy'
            else
              vim.cmd 'normal "vy'
            end

            -- construct command with v register as command to send
            -- vim.cmd(string.format('call VimuxRunCommand("%s")', vim.trim(vim.fn.getreg('v'))))
            vim.cmd "call VimuxRunCommand(@v)"
          end,
          desc = "run command under cursor",
        },
      },
      config = function()
        vim.g["VimuxOrientation"] = "h"
        vim.g["VimuxHeight"] = "35%"
      end,
    },
  },
  init = function()
    vim.g["test#strategy"] = "vimux"
    -- vim.g["test#strategy"] = "toggleterm"
    vim.g["test#preserve_screen"] = 0
    -- accommodations for Malomo's unusual folder structure on Dash
    vim.cmd [[let test#javascript#jest#file_pattern = '\v(__tests__/.*|(spec|test|__tests__))\.(js|jsx|coffee|ts|tsx)$']]
  end,
}
