local vault_dir = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Ashteka"

return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  ft = { "markdown", "livemd" },
  opts = {
    legacy_commands = false,
    dir = vault_dir,
    workspaces = {
      {
        name = "personal",
        path = vim.fs.joinpath(vault_dir, "personal"),
        strict = true,
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
      {
        name = "blvd_initiatives",
        path = vim.fs.joinpath(vault_dir, "work/initiatives"),
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
      "ObsidianOpen<cr>",
      desc = "Open Obsidian",
    },
  },
}
