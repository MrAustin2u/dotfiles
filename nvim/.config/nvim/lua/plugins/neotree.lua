return {
  "nvim-neo-tree/neo-tree.nvim",
  cmd = "Neotree",
  keys = {
    {
      "<leader>fe",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
      end,
      desc = "Explorer NeoTree (cwd)",
    },
    { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (cwd)", remap = true },
  },
  deactivate = function()
    vim.cmd([[Neotree close]])
  end,
  init = function()
    vim.g.neo_tree_remove_legacy_commands = 1
    if vim.fn.argc() == 1 then
      local stat = vim.loop.fs_stat(vim.fn.argv(0))
      if stat and stat.type == "directory" then
        require("neo-tree")
      end
    end
  end,
  opts = {
    use_libuv_file_watcher = true,
    filesystem = {
      bind_to_cwd = false,
      follow_current_file = true,
    },
    window = {
      position = "right",
      mappings = {
        ["<space>"] = "none",
      },
    },
    mappings = {
      ["a"] = {
        "add",
        -- some commands may take optional config options, see `:h neo-tree-mappings` for details
        config = {
          show_path = "none", -- "none", "relative", "absolute"
        },
      },
      ["c"] = {
        "copy",
        config = {
          show_path = "relative", -- "none", "relative", "absolute"
        },
      },
      ["m"] = {
        "move",
        config = {
          show_path = "relative",
        },
      },
    },
  },
}
