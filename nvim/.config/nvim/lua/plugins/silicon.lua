return {
  "krivahtoo/silicon.nvim",
  build = "./install.sh build",
  cmd = "Silicon",
  config = function()
    local silicon = require("silicon")

    silicon.setup({
      font = "MonoLisa",
      theme = "tokyonight_moon",
      background = "#636da6",
      output = {
        path = "/Users/aaustin/Pictures/Screenshots",
        format = "silicon_[year][month][day]_[hour][minute][second].png",
      },
    })
  end,
}
