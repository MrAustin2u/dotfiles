return {
  "MrAustin2u/silicon.lua",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    font = "MonoLisa",
    theme = "tokyonight_moon",
    bgColor = "#636da6",
  },
  config = function(_, opts)
    require("silicon").setup(opts)
    require("config.keymaps").silicon_mappings()
  end,
}
