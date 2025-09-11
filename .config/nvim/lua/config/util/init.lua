local LazyUtil, err = pcall(require, "lazy.core.util")

---@class config.util: LazyUtilCore
---@field format config.util.format
---@field lsp config.util.lsp
---@field mini config.util.mini
---@field root config.util.root
local M = {}

M.root_patterns = { ".git", "lua" }

setmetatable(M, {
  __index = function(t, k)
    if LazyUtil and LazyUtil[k] then
      return LazyUtil[k]
    end
    ---@diagnostic disable-next-line: no-unknown
    t[k] = require("config.util." .. k)
    return t[k]
  end,
})

function M.contains(tbl, item)
  for x in pairs(tbl) do
    if x == item then
      return true
    end
  end

  return false
end

function M.is_win()
  return vim.uv.os_uname().sysname:find "Windows" ~= nil
end

---@param name string
function M.get_plugin(name)
  return require("lazy.core.config").spec.plugins[name]
end

---@param name string
---@param path string?
function M.get_plugin_path(name, path)
  local plugin = M.get_plugin(name)
  path = path and "/" .. path or ""
  return plugin and (plugin.dir .. path)
end

---@param plugin string
function M.has(plugin)
  return M.get_plugin(plugin) ~= nil
end

---@param fn fun()
function M.on_very_lazy(fn)
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
      fn()
    end,
  })
end

--- This extends a deeply nested list with a key in a table
--- that is a dot-separated string.
--- The nested list will be created if it does not exist.
---@generic T
---@param t T[]
---@param key string
---@param values T[]
---@return T[]?
function M.extend(t, key, values)
  local keys = vim.split(key, ".", { plain = true })
  for i = 1, #keys do
    local k = keys[i]
    t[k] = t[k] or {}
    if type(t) ~= "table" then
      return
    end
    t = t[k]
  end
  return vim.list_extend(t, values)
end

---@param name string
function M.opts(name)
  local plugin = M.get_plugin(name)
  if not plugin then
    return {}
  end
  local Plugin = require "lazy.core.plugin"
  return Plugin.values(plugin, "opts", false)
end

-- delay notifications till vim.notify was replaced or after 500ms
function M.lazy_notify()
  local notifs = {}
  local function temp(...)
    table.insert(notifs, vim.F.pack_len(...))
  end

  local orig = vim.notify
  vim.notify = temp

  local timer = vim.uv.new_timer()
  local check = assert(vim.uv.new_check())

  local replay = function()
    timer:stop()
    check:stop()
    if vim.notify == temp then
      vim.notify = orig -- put back the original notify if needed
    end
    vim.schedule(function()
      ---@diagnostic disable-next-line: no-unknown
      for _, notif in ipairs(notifs) do
        vim.notify(vim.F.unpack_len(notif))
      end
    end)
  end

  -- wait till vim.notify has been replaced
  check:start(function()
    if vim.notify ~= temp then
      replay()
    end
  end)
  -- or if it took more than 500ms, then something went wrong
  timer:start(500, 0, replay)
end

function M.is_loaded(name)
  local Config = require "lazy.core.config"
  return Config.plugins[name] and Config.plugins[name]._.loaded
end

---@param name string
---@param fn fun(name:string)
function M.on_load(name, fn)
  if M.is_loaded(name) then
    fn(name)
  else
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(event)
        if event.data == name then
          fn(name)
          return true
        end
      end,
    })
  end
end

-- Wrapper around vim.keymap.set that will
-- not create a keymap if a lazy key handler exists.
-- It will also set `silent` to true by default.
function M.safe_keymap_set(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  local modes = type(mode) == "string" and { mode } or mode

  ---@param m string
  modes = vim.tbl_filter(function(m)
    return not (keys.have and keys:have(lhs, m))
  end, modes)

  -- do not create the keymap if a lazy keys handler exists
  if #modes > 0 then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap and not vim.g.vscode then
      ---@diagnostic disable-next-line: no-unknown
      opts.remap = nil
    end
    vim.keymap.set(modes, lhs, rhs, opts)
  end
end

---@generic T
---@param list T[]
---@return T[]
function M.dedup(list)
  local ret = {}
  local seen = {}
  for _, v in ipairs(list) do
    if not seen[v] then
      table.insert(ret, v)
      seen[v] = true
    end
  end
  return ret
end

M.CREATE_UNDO = vim.api.nvim_replace_termcodes("<c-G>u", true, true, true)
function M.create_undo()
  if vim.api.nvim_get_mode().mode == "i" then
    vim.api.nvim_feedkeys(M.CREATE_UNDO, "n", false)
  end
end

--- Gets a path to a package in the Mason registry.
--- Prefer this to `get_package`, since the package might not always be
--- available yet and trigger errors.
---@param pkg string
---@param path? string
---@param opts? { warn?: boolean }
function M.get_pkg_path(pkg, path, opts)
  pcall(require, "mason") -- make sure Mason is loaded. Will fail when generating docs
  local root = vim.env.MASON or (vim.fn.stdpath "data" .. "/mason")
  opts = opts or {}
  opts.warn = opts.warn == nil and true or opts.warn
  path = path or ""
  local ret = root .. "/packages/" .. pkg .. "/" .. path
  if opts.warn and not vim.loop.fs_stat(ret) and not require("lazy.core.config").headless() then
    M.warn(
      ("Mason package path not found for **%s**:\n- `%s`\nYou may need to force update the package."):format(pkg, path)
    )
  end
  return ret
end

--- Override the default title for notifications.
for _, level in ipairs { "info", "warn", "error" } do
  M[level] = function(msg, opts)
    opts = opts or {}
    opts.title = opts.title or "LazyVim"
    return LazyUtil[level](msg, opts)
  end
end

local cache = {} ---@type table<(fun()), table<string, any>>
---@generic T: fun()
---@param fn T
---@return T
function M.memoize(fn)
  return function(...)
    local key = vim.inspect { ... }
    cache[fn] = cache[fn] or {}
    if cache[fn][key] == nil then
      cache[fn][key] = fn(...)
    end
    return cache[fn][key]
  end
end

function M.is_helm_file(path)
  local check = vim.fs.find("Chart.yaml", { path = vim.fs.dirname(path), upward = true })
  return not vim.tbl_isempty(check)
end

function M.yaml_detect(path, _bufnr)
  if M.is_helm_file(path) then
    return "helm"
  end

  -- return yaml if nothing else
  return "yaml"
end

-- returns the root directory based on:
-- * lsp workspace folders
-- * lsp root_dir
-- * root pattern of filename of the current buffer
-- * root pattern of cwd
function M.get_root()
  local path = vim.api.nvim_buf_get_name(0)

  path = path ~= "" and vim.loop.fs_realpath(path) or nil

  local roots = {}

  if path then
    for _, client in pairs(vim.lsp.get_active_clients { bufnr = 0 }) do
      local workspace = client.config.workspace_folders
      local paths = workspace
          and vim.tbl_map(function(ws)
            return vim.uri_to_fname(ws.uri)
          end, workspace)
          or client.config.root_dir and { client.config.root_dir }
          or {}
      for _, p in ipairs(paths) do
        local r = vim.loop.fs_realpath(p)
        if path:find(r, 1, true) then
          roots[#roots + 1] = r
        end
      end
    end
  end

  table.sort(roots, function(a, b)
    return #a > #b
  end)

  local root = roots[1]

  if not root then
    path = path and vim.fs.dirname(path) or vim.loop.cwd()
    root = vim.fs.find(M.root_patterns, { path = path, upward = true })[1]
    root = root and vim.fs.dirname(root) or vim.loop.cwd()
  end

  return root
end

---@param data (string|{[string]:string})?
---@param time number?
function M.track(data, time)
  if data then
    local entry = {
      data = data,
      time = time or vim.uv.hrtime(),
    }
    table.insert(M._profiles[#M._profiles], entry)

    if not time then
      table.insert(M._profiles, entry)
    end
    return entry
  else
    ---@type LazyProfile
    local entry = table.remove(M._profiles)
    entry.time = vim.uv.hrtime() - entry.time
    return entry
  end
end

function M.exiting()
  return vim.v.exiting ~= vim.NIL
end

---@generic T
---@param list T[]
---@param fn fun(v: T):boolean?
---@return T[]
function M.filter(fn, list)
  local ret = {}
  for _, v in ipairs(list) do
    if fn(v) then
      table.insert(ret, v)
    end
  end
  return ret
end

---@generic F: fun()
---@param data (string|{[string]:string})?
---@param fn F
---@return F
function M.trackfn(data, fn)
  return function(...)
    M.track(data)
    local ok, ret = pcall(fn, ...)
    M.track()
    if not ok then
      error(ret)
    end
    return ret
  end
end

---@param name string
---@return string
function M.normname(name)
  local ret = name:lower():gsub("^n?vim%-", ""):gsub("%.n?vim$", ""):gsub("[%.%-]lua", ""):gsub("[^a-z]+", "")
  return ret
end

---@return string
function M.norm(path)
  if path:sub(1, 1) == "~" then
    local home = vim.uv.os_homedir()
    if home:sub(-1) == "\\" or home:sub(-1) == "/" then
      home = home:sub(1, -2)
    end
    path = home .. path:sub(2)
  end
  path = path:gsub("\\", "/"):gsub("/+", "/")
  return path:sub(-1) == "/" and path:sub(1, -2) or path
end

---@param opts? {level?: number}
function M.pretty_trace(opts)
  opts = opts or {}
  local Config = require "lazy.core.config"
  local trace = {}
  local level = opts.level or 2
  while true do
    local info = debug.getinfo(level, "Sln")
    if not info then
      break
    end
    if info.what ~= "C" and (Config.options.debug or not info.source:find "lazy.nvim") then
      local source = info.source:sub(2)
      if source:find(Config.options.root, 1, true) == 1 then
        source = source:sub(#Config.options.root + 1)
      end
      source = vim.fn.fnamemodify(source, ":p:~:.") --[[@as string]]
      local line = "  - " .. source .. ":" .. info.currentline
      if info.name then
        line = line .. " _in_ **" .. info.name .. "**"
      end
      table.insert(trace, line)
    end
    level = level + 1
  end
  return #trace > 0 and ("\n\n# stacktrace:\n" .. table.concat(trace, "\n")) or ""
end

---@generic R
---@param fn fun():R?
---@param opts? string|{msg:string, on_error:fun(msg)}
---@return R
function M.try(fn, opts)
  opts = type(opts) == "string" and { msg = opts } or opts or {}
  local msg = opts.msg
  -- error handler
  local error_handler = function(err)
    msg = (msg and (msg .. "\n\n") or "") .. err .. M.pretty_trace()
    if opts.on_error then
      opts.on_error(msg)
    else
      vim.schedule(function()
        M.error(msg)
      end)
    end
    return err
  end

  ---@type boolean, any
  local ok, result = xpcall(fn, error_handler)
  return ok and result or nil
end

function M.get_source()
  local f = 2
  while true do
    local info = debug.getinfo(f, "S")
    if not info then
      break
    end
    if info.what ~= "C" and not info.source:find("lazy.nvim", 1, true) and info.source ~= "@vim/loader.lua" then
      return info.source:sub(2)
    end
    f = f + 1
  end
end

-- Fast implementation to check if a table is a list
---@param t table
function M.is_list(t)
  local i = 0
  ---@diagnostic disable-next-line: no-unknown
  for _ in pairs(t) do
    i = i + 1
    if t[i] == nil then
      return false
    end
  end
  return true
end

function M.very_lazy()
  local function _load()
    vim.schedule(function()
      if vim.v.exiting ~= vim.NIL then
        return
      end
      vim.g.did_very_lazy = true
      M.track { event = "VeryLazy" }
      vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy", modeline = false })
      M.track()
    end)
  end

  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyDone",
    once = true,
    callback = function()
      if vim.v.vim_did_enter == 1 then
        _load()
      else
        vim.api.nvim_create_autocmd("UIEnter", {
          once = true,
          callback = function()
            _load()
          end,
        })
      end
    end,
  })
end

---@alias FileType "file"|"directory"|"link"
---@param path string
---@param fn fun(path: string, name:string, type:FileType):boolean?
function M.ls(path, fn)
  local handle = vim.uv.fs_scandir(path)
  while handle do
    local name, t = vim.uv.fs_scandir_next(handle)
    if not name then
      break
    end

    local fname = path .. "/" .. name

    -- HACK: type is not always returned due to a bug in luv,
    -- so fecth it with fs_stat instead when needed.
    -- see https://github.com/folke/lazy.nvim/issues/306
    if fn(fname, name, t or vim.uv.fs_stat(fname).type) == false then
      break
    end
  end
end

---@param path string
---@param fn fun(path: string, name:string, type:FileType)
function M.walk(path, fn)
  M.ls(path, function(child, name, type)
    if type == "directory" then
      M.walk(child, fn)
    end
    fn(child, name, type)
  end)
end

---@param root string
---@param fn fun(modname:string, modpath:string)
---@param modname? string
function M.walkmods(root, fn, modname)
  modname = modname and (modname:gsub("%.$", "") .. ".") or ""
  M.ls(root, function(path, name, type)
    if name == "init.lua" then
      fn(modname:gsub("%.$", ""), path)
    elseif (type == "file" or type == "link") and name:sub(-4) == ".lua" then
      fn(modname .. name:sub(1, -5), path)
    elseif type == "directory" then
      M.walkmods(path, fn, modname .. name .. ".")
    end
  end)
end

---@param modname string
---@return string
function M.topmod(modname)
  return modname:match "^[^./]+" or modname
end

---@type table<string, string[]>
M.unloaded_cache = {}

---@param modname string
---@param opts? {cache?:boolean}
function M.get_unloaded_rtp(modname, opts)
  opts = opts or {}

  local topmod = M.topmod(modname)
  if opts.cache and M.unloaded_cache[topmod] then
    return M.unloaded_cache[topmod], true
  end

  local norm = M.normname(topmod)

  ---@type string[]
  local rtp = {}
  local Config = require "lazy.core.config"
  if Config.spec then
    for _, plugin in pairs(Config.spec.plugins) do
      if not (plugin._.loaded or plugin.module == false or plugin.virtual) then
        if norm == M.normname(plugin.name) then
          table.insert(rtp, 1, plugin.dir)
        else
          table.insert(rtp, plugin.dir)
        end
      end
    end
  end
  M.unloaded_cache[topmod] = rtp
  return rtp, false
end

function M.find_root(modname)
  local paths, cached = M.get_unloaded_rtp(modname, { cache = true })

  local ret = require("lazy.core.cache").find(modname, {
    rtp = true,
    paths = paths,
    patterns = { ".lua", "" },
  })[1]

  if not ret and cached then
    paths = M.get_unloaded_rtp(modname)
    ret = require("lazy.core.cache").find(modname, {
      rtp = false,
      paths = paths,
      patterns = { ".lua", "" },
    })[1]
  end
  if ret then
    return ret.modpath:gsub("%.lua$", ""), ret.modpath
  end
end

---@param modname string
---@param fn fun(modname:string, modpath:string)
function M.lsmod(modname, fn)
  local root, match = M.find_root(modname)
  if not root then
    return
  end

  if match:sub(-4) == ".lua" then
    fn(modname, match)
    if not vim.uv.fs_stat(root) then
      return
    end
  end

  M.ls(root, function(path, name, type)
    if name == "init.lua" then
      fn(modname, path)
    elseif (type == "file" or type == "link") and name:sub(-4) == ".lua" then
      fn(modname .. "." .. name:sub(1, -5), path)
    elseif type == "directory" and vim.uv.fs_stat(path .. "/init.lua") then
      fn(modname .. "." .. name, path .. "/init.lua")
    end
  end)
end

---@generic T
---@param list T[]
---@param add T[]
---@return T[]
function M.extend(list, add)
  local idx = {}
  for _, v in ipairs(list) do
    idx[v] = v
  end
  for _, a in ipairs(add) do
    if not idx[a] then
      table.insert(list, a)
    end
  end
  return list
end

---@alias LazyNotifyOpts {lang?:string, title?:string, level?:number, once?:boolean, stacktrace?:boolean, stacklevel?:number}

---@param msg string|string[]
---@param opts? LazyNotifyOpts
function M.notify(msg, opts)
  if vim.in_fast_event() then
    return vim.schedule(function()
      M.notify(msg, opts)
    end)
  end

  opts = opts or {}
  if type(msg) == "table" then
    msg = table.concat(
      vim.tbl_filter(function(line)
        return line or false
      end, msg),
      "\n"
    )
  end
  if opts.stacktrace then
    msg = msg .. M.pretty_trace { level = opts.stacklevel or 2 }
  end
  local lang = opts.lang or "markdown"
  local n = opts.once and vim.notify_once or vim.notify
  n(msg, opts.level or vim.log.levels.INFO, {
    on_open = function(win)
      local ok = pcall(function()
        vim.treesitter.language.add "markdown"
      end)
      if not ok then
        pcall(require, "nvim-treesitter")
      end
      vim.wo[win].conceallevel = 3
      vim.wo[win].concealcursor = ""
      vim.wo[win].spell = false
      local buf = vim.api.nvim_win_get_buf(win)
      if not pcall(vim.treesitter.start, buf, lang) then
        vim.bo[buf].filetype = lang
        vim.bo[buf].syntax = lang
      end
    end,
    title = opts.title or "lazy.nvim",
  })
end

---@param msg string|string[]
---@param opts? LazyNotifyOpts
function M.error(msg, opts)
  opts = opts or {}
  opts.level = vim.log.levels.ERROR
  M.notify(msg, opts)
end

---@param msg string|string[]
---@param opts? LazyNotifyOpts
function M.info(msg, opts)
  opts = opts or {}
  opts.level = vim.log.levels.INFO
  M.notify(msg, opts)
end

---@param msg string|string[]
---@param opts? LazyNotifyOpts
function M.warn(msg, opts)
  opts = opts or {}
  opts.level = vim.log.levels.WARN
  M.notify(msg, opts)
end

---@param msg string|table
---@param opts? LazyNotifyOpts
function M.debug(msg, opts)
  if not require("lazy.core.config").options.debug then
    return
  end
  opts = opts or {}
  if opts.title then
    opts.title = "lazy.nvim: " .. opts.title
  end
  if type(msg) == "string" then
    M.notify(msg, opts)
  else
    opts.lang = "lua"
    M.notify(vim.inspect(msg), opts)
  end
end

local function can_merge(v)
  return type(v) == "table" and (vim.tbl_isempty(v) or not M.is_list(v))
end

--- Merges the values similar to vim.tbl_deep_extend with the **force** behavior,
--- but the values can be any type, in which case they override the values on the left.
--- Values will me merged in-place in the first left-most table. If you want the result to be in
--- a new table, then simply pass an empty table as the first argument `vim.merge({}, ...)`
--- Supports clearing values by setting a key to `vim.NIL`
---@generic T
---@param ... T
---@return T
function M.merge(...)
  local ret = select(1, ...)
  if ret == vim.NIL then
    ret = nil
  end
  for i = 2, select("#", ...) do
    local value = select(i, ...)
    if can_merge(ret) and can_merge(value) then
      for k, v in pairs(value) do
        ret[k] = M.merge(ret[k], v)
      end
    elseif value == vim.NIL then
      ret = nil
    elseif value ~= nil then
      ret = value
    end
  end
  return ret
end

function M.lazy_require(module)
  local mod = nil
  -- if already loaded, return the module
  -- otherwise return a lazy module
  return type(package.loaded[module]) == "table" and package.loaded[module]
      or setmetatable({}, {
        __index = function(_, key)
          mod = mod or require(module)
          return mod[key]
        end,
      })
end

---@param t table
---@param key string|string[]
---@return any
function M.key_get(t, key)
  local path = type(key) == "table" and key or vim.split(key, ".", true)
  local value = t
  for _, k in ipairs(path) do
    if type(value) ~= "table" then
      return value
    end
    value = value[k]
  end
  return value
end

---@param t table
---@param key string|string[]
---@param value any
function M.key_set(t, key, value)
  local path = type(key) == "table" and key or vim.split(key, ".", true)
  local last = t
  for i = 1, #path - 1 do
    local k = path[i]
    if type(last[k]) ~= "table" then
      last[k] = {}
    end
    last = last[k]
  end
  last[path[#path]] = value
end

return M
