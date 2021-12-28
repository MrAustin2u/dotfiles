vim.g.mapleader = " "

local ok, reload = pcall(require, 'plenary.reload')
RELOAD = ok and reload.reload_module or function(...)
  return ...
end
function R(name)
  RELOAD(name)
  return require(name)
end

------------------------------------------------------------------------
-- Plugin Configurations
------------------------------------------------------------------------
R "aa.globals"
R "aa.plugins"
R "aa.lsp"
R "aa.options"
R "aa.keybindings"
