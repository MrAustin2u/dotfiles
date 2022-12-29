local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

math.randomseed(os.time())

local function button(sc, txt, keybind, keybind_opts)
  local b = dashboard.button(sc, txt, keybind, keybind_opts)
  b.opts.hl = "Function"
  b.opts.hl_shortcut = "Type"
  return b
end

local function pick_color()
  local clrs = { "String", "Identifier", "Keyword", "Number" }
  return clrs[math.random(#clrs)]
end

local function footer()
  local datetime = os.date("%m-%d-%Y  %H:%M %AM")
  return {
    vim.loop.cwd(),
    datetime,
  }
end

-- REF: https://patorjk.com/software/taag/#p=display&f=Elite&t=ASHTEKA
dashboard.section.header.val = {

  " █████╗ ███████╗██╗  ██╗████████╗███████╗██╗  ██╗ █████╗ ",
  "██╔══██╗██╔════╝██║  ██║╚══██╔══╝██╔════╝██║ ██╔╝██╔══██╗",
  "███████║███████╗███████║   ██║   █████╗  █████╔╝ ███████║",
  "██╔══██║╚════██║██╔══██║   ██║   ██╔══╝  ██╔═██╗ ██╔══██║",
  "██║  ██║███████║██║  ██║   ██║   ███████╗██║  ██╗██║  ██║",
  "╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝",
}

dashboard.section.header.opts.hl = pick_color()
dashboard.section.buttons.val = {
  button("m", "  Recently opened files", "<cmd>lua require('telescope.builtin').oldfiles()<cr>"),
  button("f", "  Find file", "<cmd>lua require('telescope.builtin').find_files()<cr>"),
  button("a", "  Find word", "<cmd>lua require('telescope.builtin').live_grep()<cr>"),
  button("e", "  New file", "<cmd>ene <BAR> startinsert <CR>"),
  button("p", "  Update plugins", "<cmd>PackerUpdate<CR>"),
  button("q", "  Quit", "<cmd>qa<CR>"),
}

dashboard.section.footer.val = footer()
dashboard.section.footer.opts.hl = "Constant"
dashboard.section.footer.opts.position = "center"

alpha.setup(dashboard.opts)
