vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.loader.enable()

local modules = {
  "config.globals",
  "config.options",
  "config.keymaps",
}

for _, module in ipairs(modules) do
  local ok, err = pcall(require, module)
  if not ok then
    error("Error loading " .. module .. "\n\n" .. err)
  end
end

require "config.lazy"
