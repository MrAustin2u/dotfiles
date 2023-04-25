local present, dashboard = pcall(require, 'dashboard')

if not present then
  return
end

local M = {}

local opts = {
  theme = "doom",
  config = {
    header = {
      "                                                       ",
      "                                                       ",
      "                        ______________                 ",
      "                       /             /|                ",
      "                      /             / |                ",
      "                     /____________ /  |                ",
      "                    | ___________ |   |                ",
      "                    ||$ nvim █   ||   |                ",
      "                    ||           ||   |                ",
      "                    ||           ||   |                ",
      "                    ||___________||   |                ",
      "                    |   _______   |  /                 ",
      "                   /|  (_______)  | /                  ",
      "                  ( |_____________|/                   ",
      "                  \\                                   ",
      "               .=======================.               ",
      "               | ::::::::::::::::  ::: |               ",
      "               | ::::::::::::::[]  ::: |               ",
      "               |   -----------     ::: |               ",
      "               `-----------------------`               ",
      "                                                       ",
      "                                                       ",
      "                                                       ",
    },
    center = {
      { icon = "   ", desc = "Find File                      ", key = "f", action = "Telescope find_files" },
      { icon = "   ", desc = "Find Word                      ", key = "g", action = "Telescope live_grep" },
      { icon = "   ", desc = "New File                       ", key = "n", action = "enew" },
      { icon = "   ", desc = "Update Plugins                 ", key = "u", action = "Lazy sync" },
      { icon = "   ", desc = "Settings                       ", key = "o", action = "edit $MYVIMRC" },
      { icon = "   ", desc = "Exit                           ", key = "q", action = "exit" },
    },
    footer = {},
  },
}

M.setup = function()
  dashboard.setup(opts)
end

return M
