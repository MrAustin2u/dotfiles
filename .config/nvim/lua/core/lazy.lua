local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({ import = "plugins" }, {
  install = {
    missing = true,
    colorscheme = { "habamax" }
  },
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    enabled = true,
    notify = false,
  },
  ui = {
    -- border = "rounded"
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        "rplugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- Load vim.pack plugins after init completes (vim_did_init=1 → load=true,
-- which sources plugin/ scripts so commands like TmuxNavigate* are defined)
vim.schedule(function()
  -- Restore site directory in packpath (lazy.nvim's rtp reset removes it)
  vim.opt.packpath:append(vim.fn.stdpath("data") .. "/site")

  for _, f in ipairs(vim.fn.glob(vim.fn.stdpath("config") .. "/lua/packs/*.lua", false, true)) do
    dofile(f)
  end
end)
