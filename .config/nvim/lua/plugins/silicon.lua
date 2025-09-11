return {
  "michaelrommel/nvim-silicon",
  lazy = true,
  cmd = "Silicon",
  main = "nvim-silicon",
  keys = {
    {
      "<leader>sc",
      function()
        require("nvim-silicon").clip()
      end,
      desc = "Copy code screenshot to clipboard",
    },
    {
      "<leader>sf",
      function()
        require("nvim-silicon").file()
      end,
      desc = "Save code screenshot as file",
    },
    {
      "<leader>ss",
      function()
        require("nvim-silicon").shoot()
      end,
      desc = "Create code screenshot",
    },
  },
  opts = {
    -- Configuration here, or leave empty to use defaults
    line_offset = function(args)
      return args.line1
    end,
    font = "MonoLisa",
    theme = "tokyonight_moon",
    background = "#636da6",
    output = {
      path = "/Users/aaustin/Pictures/Screenshots",
      format = "silicon_[year][month][day]_[hour][minute][second].png",
    },
  },
}
