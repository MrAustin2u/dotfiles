local api, fn, vcmd, keymap = vim.api, vim.fn, vim.cmd, vim.keymap

_G.__aa_global_callbacks = __aa_global_callbacks or {}
_G.aa = {
  _store = __aa_global_callbacks,
  functions = {},
  dirs = {},
}

-- inspect the contents of an object very quickly
-- in your code or from the command-line:
-- @see: https://www.reddit.com/r/neovim/comments/p84iu2/useful_functions_to_explore_lua_objects/
-- USAGE:
-- in lua: P({1, 2, 3})
-- in commandline: :lua P(vim.loop)
---@vararg any
function _G.P(...)
  local objects, v = {}, nil
  for i = 1, select("#", ...) do
    v = select(i, ...)
    table.insert(objects, vim.inspect(v))
  end

  print(table.concat(objects, "\n"))
  return ...
end

function _G.dump_text(...)
  local objects, v = {}, nil
  for i = 1, select("#", ...) do
    v = select(i, ...)
    table.insert(objects, vim.inspect(v))
  end

  local lines = vim.split(table.concat(objects, "\n"), "\n")
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  vim.fn.append(lnum, lines)
  return ...
end

local get_map_options = function(custom_options)
  local options = { noremap = true, silent = true }
  if custom_options then
    options = vim.tbl_extend("force", options, custom_options) or options
  end
  return options
end

local L = vim.log.levels

aa._create = function(f)
  table.insert(aa._store, f)
  return #aa._store
end

aa.table = {
  some = function(tbl, cb)
    for k, v in pairs(tbl) do
      if cb(k, v) then
        return true
      end
    end
    return false
  end,
}

aa.log = function(msg, hl, reason)
  if hl == nil and reason == nil then
    api.nvim_echo({ { msg } }, true, {})
  else
    local name = "aa.im"
    local prefix = name .. " -> "
    if reason ~= nil then
      prefix = name .. " -> " .. reason .. "\n"
    end
    hl = hl or "DiagnosticDefaultInformation"
    api.nvim_echo({ { prefix, hl }, { msg } }, true, {})
  end
end

aa.warn = function(msg, reason)
  aa.log(msg, "DiagnosticDefaultWarning", reason)
end

aa.error = function(msg, reason)
  aa.log(msg, "DiagnosticDefaultError", reason)
end

aa.get_log_string = function(label, level)
  local display_level = "[DEBUG]"
  local hl = "Todo"

  if level ~= nil then
    if level == L.ERROR then
      display_level = "[ERROR]"
      hl = "ErrorMsg"
    elseif level == L.WARN then
      display_level = "[WARNING]"
      hl = "WarningMsg"
    end
  end

  local str = string.format("%s %s", display_level, label)

  return str, hl
end

aa.executable = function(e)
  return fn.executable(e) > 0
end

aa._execute = function(id, args)
  local func = aa._store[id]
  if not func then
    aa.error("function for id doesn't exist: " .. id)
  end

  aa._store[id](args)
end

-- a safe module loader
aa.load = function(module, opts)
  opts = opts or { silent = false, safe = false }

  if opts.key == nil then
    opts.key = "loader"
  end

  local ok, result = pcall(require, module)

  if not ok and (opts.silent ~= nil and not opts.silent) then
    -- REF: https://github.com/neovim/neovim/blob/master/src/nvim/lua/vim.lua#L421
    local level = L.ERROR
    local reason = aa.get_log_string("loading failed", level)

    aa.error(result, reason)
  end

  if opts.safe ~= nil and opts.safe == true then
    return ok, result
  else
    return result
  end
end

aa.safe_require = function(module, opts)
  opts = vim.tbl_extend("keep", { safe = true }, opts or {})
  return aa.load(module, opts)
end

-- commands

aa.au = function(s, override)
  override = override or false
  if override then
    vcmd("au! " .. s)
  else
    vcmd("au " .. s)
  end
end

aa.command = function(name, func)
  vim.cmd(string.format("command! %s %s", name, func))
end

aa.lua_command = function(name, func)
  aa.command(name, "lua " .. func)
end

aa.buf_command = function(bufnr, name, func, opts)
  api.nvim_buf_create_user_command(bufnr, name, func, opts or {})
end

-- mappings

aa.buf_map = function(bufnr, mode, target, source)
  keymap.set(mode, target, source, get_map_options({ buffer = bufnr or 0 }))
end

aa.imap = function(tbl)
  keymap.set("i", tbl[1], tbl[2], tbl[3])
end

aa.nmap = function(tbl)
  keymap.set("n", tbl[1], tbl[2], tbl[3])
end

aa.vmap = function(tbl)
  keymap.set("v", tbl[1], tbl[2], tbl[3])
end

aa.buf_nnoremap = function(opts)
  if opts[3] == nil then
    opts[3] = {}
  end
  opts[3] = { buffer = 0 }

  aa.nmap(opts)
end
aa.buf_inoremap = function(opts)
  if opts[3] == nil then
    opts[3] = {}
  end
  opts[3] = { buffer = 0 }

  aa.imap(opts)
end

aa.buf_vnoremap = function(opts)
  if opts[3] == nil then
    opts[3] = {}
  end
  opts[3] = { buffer = 0 }

  aa.vmap(opts)
end

aa.save_and_source = function()
  if vim.bo.filetype == "vim" then
    vcmd("silent! write")
    vcmd("source %")
    aa.log("Saving and sourcing vim file...")
  elseif vim.bo.filetype == "lua" then
    vcmd("silent! write")
    vcmd("luafile %")
    aa.log("Saving and sourcing lua file...")
  end
end

return aa
