local vault_dir = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Ashteka"

return {
  "epwalsh/obsidian.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  version = "*",
  ft = { "markdown", "livemd" },
  cmd = {
    "ObsidianNew",
    "ObsidianOpen",
    "ObsidianOpen",
    "ObsidianSearch",
    "ObsidianToday",
    "ObsidianTomorrow",
    "ObsidianWorkspace",
    "ObsidianYesterday",
  },
  opts = {
    dir = vault_dir,
    workspaces = {
      {
        name = "personal",
        path = vim.fs.joinpath(vault_dir, "personal"),
      },
      {
        name = "work",
        path = vim.fs.joinpath(vault_dir, "work"),
      },
      {
        name = "blvd_sched_elixir_scripts",
        path = vim.fs.joinpath(vault_dir, "work/elixir_scripts"),
      },
      {
        name = "blvd_standup",
        path = vim.fs.joinpath(vault_dir, "work/standup"),
      },
    },
    daily_notes = {
      folder = "dailies",
    },
    completion = {
      nvim_cmp = false,
    },
    ui = {
      enable = false,
    },
    note_id_func = function(title)
      -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
      if title ~= nil then
        -- If title is given, transform it into valid file name.
        return title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        -- If title is nil, just add 4 random uppercase letters to the suffix.
        local suffix = ""
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
        return tostring(os.time()) .. "-" .. suffix
      end
    end,
    templates = {
      folder = "templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M %P",
    },
  },
  keys = {
    {
      "<space>oo",
      function()
        require("telescope").extensions.file_browser.file_browser { path = vault_dir }
      end,
      desc = "Open Obsidian vault",
    },
    {
      "<space>ow",
      "<cmd>ObsidianWorkspace<cr>",
      desc = "Switch Obsidian workspace",
    },
    {
      "<space>on",
      "<cmd>ObsidianNew<cr>",
      desc = "New Obsidian note",
    },
    {
      "<space>ot",
      "<cmd>ObsidianNewFromTemplate<cr>",
      desc = "New Obsidian note from template",
    },
  },
}
