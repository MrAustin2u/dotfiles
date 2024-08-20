return {
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {
    library = {
      { "lazy.nvim", words = { "lazy", "LazySpec", "LazyKeys", "LazyKeysSpec" } },
      { path = "luvit-meta/library", words = { "vim%.uv" } },
      { path = "wezterm-types", mods = { "wezterm" } },
    },
  },
}