local api, fn, vcmd = vim.api, vim.fn, vim.cmd

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
        options = vim.tbl_extend("force", options, custom_options)
    end
    return options
end

local L = vim.log.levels

aa._create = function(f)
  table.insert(aa._store, f)
  return #aa._store
end

aa.inspect = function(label, v, opts)
  opts = opts or {}
  opts = vim.tbl_deep_extend("keep", opts, { data_before = true, level = L.INFO })

  local log_str, hl = aa.get_log_string(label, opts.level)

  -- presently no better API to get the current lsp log level
  -- L.DEBUG == 3
  if opts.level == L.DEBUG and (aa.get_log_level() == L.DEBUG or aa.get_log_level() == 3) then
    if opts.data_before then
      aa.P(v)
      aa.log(log_str, hl)
    else
      aa.log(log_str, hl)
      aa.P(v)
    end
  end

  return v
end

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

aa.buf_map = function(bufnr, mode, target, source, opts)
  api.nvim_buf_set_keymap(bufnr or 0, mode, target, source, get_map_options(opts))
end

-- autocommands

aa.au = function(s, override)
  override = override or false
  if override then
    vcmd("au! " .. s)
  else
    vcmd("au " .. s)
  end
end

-- mappings

local function make_keymap_fn(mode, o)
  -- copy the opts table as extends will mutate opts
  local parent_opts = vim.deepcopy(o)
  return function(combo, mapping, opts)
    assert(combo ~= mode, string.format("The combo should not be the same as the mode for %s", combo))
    local _opts = opts and vim.deepcopy(opts) or {}

    if type(mapping) == "function" then
      local fn_id = aa._create(mapping)
      mapping = string.format("<cmd>lua aa._execute(%s)<cr>", fn_id)
    end

    if _opts.bufnr then
      local bufnr = _opts.bufnr
      _opts.bufnr = nil
      _opts = vim.tbl_extend("keep", _opts, parent_opts)
      api.nvim_buf_set_keymap(bufnr, mode, combo, mapping, _opts)
    else
      api.nvim_set_keymap(mode, combo, mapping, vim.tbl_extend("keep", _opts, parent_opts))
    end
  end
end

local map_opts = {noremap = false, silent = true}
aa.nmap = make_keymap_fn("n", map_opts)
aa.xmap = make_keymap_fn("x", map_opts)
aa.imap = make_keymap_fn("i", map_opts)
aa.vmap = make_keymap_fn("v", map_opts)
aa.omap = make_keymap_fn("o", map_opts)
aa.tmap = make_keymap_fn("t", map_opts)
aa.smap = make_keymap_fn("s", map_opts)
aa.cmap = make_keymap_fn("c", map_opts)

local noremap_opts = {noremap = true, silent = true}
aa.nnoremap = make_keymap_fn("n", noremap_opts)
aa.xnoremap = make_keymap_fn("x", noremap_opts)
aa.vnoremap = make_keymap_fn("v", noremap_opts)
aa.inoremap = make_keymap_fn("i", noremap_opts)
aa.onoremap = make_keymap_fn("o", noremap_opts)
aa.tnoremap = make_keymap_fn("t", noremap_opts)
aa.cnoremap = make_keymap_fn("c", noremap_opts)

aa.has_map = function(map, mode)
  mode = mode or "n"
  return fn.maparg(map, mode) ~= ""
end


return aa
