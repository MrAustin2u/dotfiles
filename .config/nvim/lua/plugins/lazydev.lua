return {
  "folke/lazydev.nvim",
  dependencies = {
    -- vim.uv typings
    { "Bilal2453/luvit-meta", lazy = true },
  },
  ft = "lua",
  opts = {
    library = {
      { "lazy.nvim", words = { "lazy", "LazySpec", "LazyKeys", "LazyKeysSpec" } },
      { path = "luvit-meta/library", words = { "vim%.uv" } },
      { path = "wezterm-types", mods = { "wezterm" } },
      { path = "snacks.nvim", words = { "Snacks" } },
    },
  },
}
