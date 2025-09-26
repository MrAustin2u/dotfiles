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
      mode = { "n", "v" },
      desc = "Copy code screenshot to clipboard",
    },
    {
      "<leader>sf",
      function()
        require("nvim-silicon").file()
      end,
      desc = "Save code screenshot as file",
    },
  },
  opts = {
    -- Configuration here, or leave empty to use defaults
    line_offset = function(args)
      return args.line1
    end,
    font = "MonoLisa",
    theme = "Dracula",
    background = "#636da6",
    output = function()
      return "/Users/aaustin/Pictures/Screenshots/" .. os.date "!%Y-%m-%d" .. "_code.png"
    end,
  },
}
