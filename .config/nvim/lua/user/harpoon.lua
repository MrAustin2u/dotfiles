local M = {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
}

function M.config()
  local harpoon = require("harpoon")

  harpoon:setup()

  -- basic telescope configuration
  local conf = require("telescope.config").values
  local function toggle_telescope(harpoon_files)
    local file_paths = {}
    for _, item in ipairs(harpoon_files.items) do
      table.insert(file_paths, item.value)
    end

    require("telescope.pickers").new({}, {
      prompt_title = "Harpoon",
      finder = require("telescope.finders").new_table({
        results = file_paths,
      }),
      previewer = conf.file_previewer({}),
      sorter = conf.generic_sorter({}),
    }):find()
  end

  -- mappings
  vim.keymap.set("n", "<leader>a", function()
      harpoon:list():add()
      vim.notify "󱡅  marked file"
    end,
    { noremap = true, silent = true, desc = "[harpoon] add file" })
  vim.keymap.set("n", "<TAB>", function() harpoon:list():next() end,
    { noremap = true, silent = true, desc = "[harpoon] next buffer" })
  vim.keymap.set("n", "<S-TAB>", function() harpoon:list():prev() end,
    { noremap = true, silent = true, desc = "[harpoon] previous buffer" })
  vim.keymap.set("n", "<C-e>", function() toggle_telescope(harpoon:list()) end,
    { noremap = true, silent = true, desc = "[harpoon] Open window" })
end

return M
